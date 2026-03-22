import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cryptography/cryptography.dart' show SecretKey, Mac;
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/entry.dart';
import 'encryption_service.dart';
import 'storage_service.dart';

/// LAN Sync Service - Lokale P2P Synchronisation
/// 
/// Funktionsweise:
/// 1. Device Discovery via mDNS/Bonjour im lokalen WLAN
/// 2. Pairing via QR-Code oder 6-stelligem Code
/// 3. Verschlüsselter Datentransfer (AES-256-GCM)
/// 4. CRDT-basierte Konfliktlösung
/// 5. Inkrementelle Synchronisation
class LanSyncService {
  final StorageService _storage;
  final EncryptionService _encryption;
  final _uuid = const Uuid();
  
  // Netzwerk-Konfiguration
  static const int discoveryPort = 37421;
  static const int syncPort = 37422;
  static const String serviceType = '_lifesync._tcp';
  
  // Status
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _discoveredDevicesController = StreamController<List<DiscoveredDevice>>.broadcast();
  final _syncProgressController = StreamController<SyncProgress>.broadcast();
  
  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;
  Stream<List<DiscoveredDevice>> get discoveredDevices => _discoveredDevicesController.stream;
  Stream<SyncProgress> get syncProgress => _syncProgressController.stream;
  
  // Aktuelle Verbindungen
  final Map<String, PairedDevice> _pairedDevices = {};
  final Map<String, Socket> _activeConnections = {};
  
  // Discovery
  RawDatagramSocket? _discoverySocket;
  Timer? _announcementTimer;
  Timer? _discoveryTimer;
  
  // Server
  ServerSocket? _serverSocket;
  
  // Eigenes Gerät
  late final SyncDevice _thisDevice;
  
  LanSyncService(this._storage, this._encryption) {
    _thisDevice = SyncDevice(
      id: _uuid.v4(),
      name: _generateDeviceName(),
      platform: Platform.operatingSystem,
      version: '1.0.0',
    );
  }
  
  // ==================== DISCOVERY ====================
  
  /// Starte Device Discovery im WLAN
  Future<void> startDiscovery() async {
    // UDP Socket für Discovery
    _discoverySocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      discoveryPort,
    );
    
    // Broadcast Listener
    _discoverySocket!.listen(_handleDiscoveryPacket);
    
    // Periodische Ankündigungen
    _announcementTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _broadcastAnnouncement(),
    );
    
    // Suche nach anderen Geräten
    _discoveryTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _sendDiscoveryRequest(),
    );
    
    _syncStatusController.add(SyncStatus.discovering);
  }
  
  /// Stoppe Discovery
  Future<void> stopDiscovery() async {
    _announcementTimer?.cancel();
    _discoveryTimer?.cancel();
    _discoverySocket?.close();
    _discoverySocket = null;
  }
  
  /// Sende Ankündigung ins WLAN
  void _broadcastAnnouncement() {
    final packet = _createDiscoveryPacket(DiscoveryMessageType.announcement);
    final data = utf8.encode(jsonEncode(packet));
    
    // Broadcast an alle Geräte im WLAN
    _discoverySocket?.send(
      data,
      InternetAddress('255.255.255.255'),
      discoveryPort,
    );
  }
  
  /// Sende Discovery-Request
  void _sendDiscoveryRequest() {
    final packet = _createDiscoveryPacket(DiscoveryMessageType.request);
    final data = utf8.encode(jsonEncode(packet));
    
    _discoverySocket?.send(
      data,
      InternetAddress('255.255.255.255'),
      discoveryPort,
    );
  }
  
  /// Verarbeite eingehende Discovery-Pakete
  void _handleDiscoveryPacket(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    
    final datagram = _discoverySocket?.receive();
    if (datagram == null) return;
    
    try {
      final packet = jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>;
      final typeIndex = packet['type'] as int?;
      if (typeIndex == null || typeIndex < 0 || typeIndex >= DiscoveryMessageType.values.length) return;
      final messageType = DiscoveryMessageType.values[typeIndex];

      // Ignoriere eigene Pakete
      if (packet['deviceId'] == _thisDevice.id) return;

      switch (messageType) {
        case DiscoveryMessageType.announcement:
        case DiscoveryMessageType.response:
          _handleDeviceDiscovered(packet, datagram.address.address);
          break;
        case DiscoveryMessageType.request:
          _sendDiscoveryResponse(datagram.address);
          break;
      }
    } catch (e) {
      assert(() { debugPrint('[LAN Sync] Invalid discovery packet: $e'); return true; }());
    }
  }
  
  /// Gerät entdeckt
  void _handleDeviceDiscovered(Map<String, dynamic> packet, String ipAddress) {
    final device = DiscoveredDevice(
      id: packet['deviceId'] as String,
      name: packet['deviceName'] as String,
      platform: packet['platform'] as String,
      ipAddress: ipAddress,
      port: packet['port'] as int? ?? syncPort,
      discoveredAt: DateTime.now(),
      isPaired: _pairedDevices.containsKey(packet['deviceId']),
    );
    
    // Aktualisiere Liste
    final currentDevices = <String, DiscoveredDevice>{};
    for (final d in _pairedDevices.values) {
      currentDevices[d.id] = DiscoveredDevice(
        id: d.id,
        name: d.name,
        platform: d.platform,
        ipAddress: d.ipAddress,
        port: d.port,
        discoveredAt: DateTime.now(),
        isPaired: true,
      );
    }
    currentDevices[device.id] = device;
    
    _discoveredDevicesController.add(currentDevices.values.toList());
  }
  
  /// Sende Discovery-Response
  void _sendDiscoveryResponse(InternetAddress address) {
    final packet = _createDiscoveryPacket(DiscoveryMessageType.response);
    final data = utf8.encode(jsonEncode(packet));
    
    _discoverySocket?.send(data, address, discoveryPort);
  }
  
  /// Erstelle Discovery-Paket
  Map<String, dynamic> _createDiscoveryPacket(DiscoveryMessageType type) {
    return {
      'type': type.index,
      'deviceId': _thisDevice.id,
      'deviceName': _thisDevice.name,
      'platform': _thisDevice.platform,
      'version': _thisDevice.version,
      'port': syncPort,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }
  
  // ==================== SERVER ====================
  
  /// Starte Sync-Server
  Future<void> startServer() async {
    _serverSocket = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      syncPort,
    );
    
    _serverSocket!.listen(_handleIncomingConnection);
    
    debugPrint('[LAN Sync] Server gestartet auf Port $syncPort');
  }
  
  /// Stoppe Server
  Future<void> stopServer() async {
    await _serverSocket?.close();
    _serverSocket = null;
  }
  
  /// Behandle eingehende Verbindung
  void _handleIncomingConnection(Socket socket) {
    debugPrint('[LAN Sync] Eingehende Verbindung von ${socket.remoteAddress.address}');
    
    _handleConnection(socket);
  }
  
  // ==================== PAIRING ====================
  
  /// Generiere Pairing-Code (6-stellig)
  PairingInfo generatePairingCode() {
    final random = Random.secure();
    final code = (100000 + random.nextInt(900000)).toString();
    
    return PairingInfo(
      code: code,
      deviceId: _thisDevice.id,
      deviceName: _thisDevice.name,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      encryptionKey: _uuid.v4(), // Session Key
    );
  }
  
  /// Generiere QR-Code für Pairing
  String generatePairingQrCode() {
    final pairingInfo = generatePairingCode();
    
    final qrData = {
      'type': 'lifesync_pairing',
      'code': pairingInfo.code,
      'deviceId': pairingInfo.deviceId,
      'deviceName': pairingInfo.deviceName,
      'key': pairingInfo.encryptionKey,
      'ip': _getLocalIpAddress(),
      'port': syncPort,
    };
    
    return jsonEncode(qrData);
  }
  
  /// Pairing mit Code
  Future<PairedDevice> pairWithCode(String code, String deviceId) async {
    // Validiere Code (in realer Implementierung würde dieser vom anderen Gerät kommen)
    
    final socket = await _connectToDevice(deviceId);
    
    // Sende Pairing-Request
    final pairingRequest = {
      'type': SyncMessageType.pairingRequest.index,
      'code': code,
      'device': _thisDevice.toJson(),
    };
    
    socket.write(jsonEncode(pairingRequest));
    
    // Warte auf Response
    final response = await _readMessage(socket);
    
    if (response['success'] == true) {
      final pairedDevice = PairedDevice(
        id: deviceId,
        name: response['deviceName'] as String,
        platform: response['platform'] as String,
        ipAddress: socket.remoteAddress.address,
        port: syncPort,
        pairedAt: DateTime.now(),
        encryptionKey: response['encryptionKey'] as String,
      );
      
      _pairedDevices[deviceId] = pairedDevice;
      _activeConnections[deviceId] = socket;
      
      // Speichere Pairing
      await _savePairedDevices();
      
      _syncStatusController.add(SyncStatus.paired);
      
      return pairedDevice;
    } else {
      socket.destroy();
      throw Exception(response['error'] ?? 'Pairing fehlgeschlagen');
    }
  }
  
  /// Verarbeite Pairing-Request
  Future<void> _handlePairingRequest(Socket socket, Map<String, dynamic> data) async {
    final device = SyncDevice.fromJson(data['device'] as Map<String, dynamic>);
    
    // Validiere Code (hier vereinfacht)
    // In echter Implementierung würde der Code mit einem generierten verglichen
    
    final sessionKey = _uuid.v4();
    
    final pairedDevice = PairedDevice(
      id: device.id,
      name: device.name,
      platform: device.platform,
      ipAddress: socket.remoteAddress.address,
      port: syncPort,
      pairedAt: DateTime.now(),
      encryptionKey: sessionKey,
    );
    
    _pairedDevices[device.id] = pairedDevice;
    _activeConnections[device.id] = socket;
    
    await _savePairedDevices();
    
    // Sende Response
    final response = {
      'success': true,
      'deviceName': _thisDevice.name,
      'platform': _thisDevice.platform,
      'encryptionKey': sessionKey,
    };
    
    socket.write(jsonEncode(response));
  }
  
  // ==================== SYNC PROTOCOL ====================
  
  /// Starte Sync mit einem gepaarten Gerät
  Future<void> startSync(String deviceId) async {
    final device = _pairedDevices[deviceId];
    if (device == null) {
      throw Exception('Gerät nicht gepaart');
    }
    
    _syncStatusController.add(SyncStatus.syncing);
    
    Socket? socket = _activeConnections[deviceId];
    
    // Verbinde falls nicht verbunden
    if (socket == null) {
      socket = await _connectToDevice(deviceId);
      _activeConnections[deviceId] = socket;
    }
    
    try {
      // 1. Exchange timestamps
      await _exchangeSyncMetadata(socket, device);
      
      // 2. Sync entries
      await _syncEntries(socket, device);
      
      // 3. Sync media
      await _syncMedia(socket, device);
      
      _syncStatusController.add(SyncStatus.synced);
      
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      rethrow;
    }
  }
  
  /// Exchange Sync Metadata
  Future<void> _exchangeSyncMetadata(Socket socket, PairedDevice device) async {
    // Hole lokale Sync-Info
    final localSyncInfo = await _getLocalSyncInfo();
    
    final request = {
      'type': SyncMessageType.syncMetadata.index,
      'syncInfo': localSyncInfo.toJson(),
    };
    
    socket.write(jsonEncode(request));
    
    final response = await _readMessage(socket);
    final remoteSyncInfo = SyncInfo.fromJson(response['syncInfo'] as Map<String, dynamic>);
    
    device.lastSyncInfo = remoteSyncInfo;
  }
  
  /// Sync Entries
  Future<void> _syncEntries(Socket socket, PairedDevice device) async {
    // Registriere Listener zuerst, bevor gesendet wird (verhindert Race Condition)
    socket.listen((data) async {
      try {
        final message = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
        await _handleSyncMessage(socket, message, device);
      } catch (e) {
        assert(() { debugPrint('[LAN Sync] Entry message parse error: $e'); return true; }());
      }
    });

    // Hole Einträge die seit letztem Sync geändert wurden
    final localEntries = await _getChangedEntries(device.lastSyncInfo?.lastSyncAt);

    // Sende lokale Änderungen
    for (final entry in localEntries) {
      final message = {
        'type': SyncMessageType.entryUpdate.index,
        'entry': await _encryptEntry(entry, device.encryptionKey),
      };

      socket.write(jsonEncode(message));

      _syncProgressController.add(SyncProgress(
        phase: SyncPhase.entries,
        current: localEntries.indexOf(entry) + 1,
        total: localEntries.length,
      ));
    }
  }
  
  /// Sync Media
  Future<void> _syncMedia(Socket socket, PairedDevice device) async {
    // Implementierung für Medien-Sync
    // Ähnlich wie Entry-Sync, aber mit binären Daten
  }
  
  /// Handle Sync Message
  Future<void> _handleSyncMessage(Socket socket, Map<String, dynamic> message, PairedDevice device) async {
    final typeIndex = message['type'] as int?;
    if (typeIndex == null || typeIndex < 0 || typeIndex >= SyncMessageType.values.length) {
      assert(() { debugPrint('[LAN Sync] Unknown sync message type: $typeIndex'); return true; }());
      return;
    }
    final messageType = SyncMessageType.values[typeIndex];
    
    switch (messageType) {
      case SyncMessageType.entryUpdate:
        await _handleEntryUpdate(message, device);
        break;
      case SyncMessageType.entryDelete:
        await _handleEntryDelete(message, device);
        break;
      case SyncMessageType.mediaUpdate:
        await _handleMediaUpdate(message, device);
        break;
      case SyncMessageType.syncComplete:
        _syncStatusController.add(SyncStatus.synced);
        break;
      default:
        break;
    }
  }
  
  /// Handle Entry Update
  Future<void> _handleEntryUpdate(Map<String, dynamic> message, PairedDevice device) async {
    final encryptedEntry = message['entry'] as String;
    final entry = await _decryptEntry(encryptedEntry, device.encryptionKey);
    
    // Konfliktlösung
    final existingEntry = await _storage.loadEntry(entry.id);
    
    if (existingEntry != null) {
      // CRDT Merge
      final mergedEntry = _resolveConflict(existingEntry, entry);
      await _storage.saveEntry(mergedEntry);
    } else {
      await _storage.saveEntry(entry);
    }
  }
  
  /// Handle Entry Delete
  Future<void> _handleEntryDelete(Map<String, dynamic> message, PairedDevice device) async {
    final entryId = message['entryId'] as int;
    await _storage.deleteEntry(entryId);
  }
  
  /// Handle Media Update
  Future<void> _handleMediaUpdate(Map<String, dynamic> message, PairedDevice device) async {
    // Implementierung für Medien-Empfang
  }
  
  // ==================== CONFLICT RESOLUTION ====================
  
  /// CRDT-basierte Konfliktlösung
  Entry _resolveConflict(Entry local, Entry remote) {
    // Last-Write-Wins mit Timestamp
    if (remote.updatedAt.isAfter(local.updatedAt)) {
      return remote;
    }
    
    // Bei gleichem Timestamp: Hash-basierte Entscheidung
    if (remote.updatedAt == local.updatedAt) {
      final localHash = _computeEntryHash(local);
      final remoteHash = _computeEntryHash(remote);
      
      if (remoteHash.compareTo(localHash) > 0) {
        return remote;
      }
    }
    
    return local;
  }
  
  /// Compute Entry Hash for conflict resolution
  String _computeEntryHash(Entry entry) {
    final content = '${entry.id}${entry.uuid}${entry.updatedAt.millisecondsSinceEpoch}';
    // In echter Implementierung: SHA-256
    return content.hashCode.toRadixString(16);
  }
  
  // ==================== ENCRYPTION ====================
  
  /// Verschlüssele Entry für Transfer
  Future<String> _encryptEntry(Entry entry, String key) async {
    final json = jsonEncode(entry.toJson());
    final keyBytes = SecretKey(utf8.encode(key).sublist(0, 32));
    final encrypted = await _encryption.encrypt(
      Uint8List.fromList(utf8.encode(json)),
      keyBytes,
    );
    return base64Encode(encrypted.ciphertext) +
        '.' +
        base64Encode(encrypted.nonce) +
        '.' +
        base64Encode(encrypted.mac.bytes);
  }

  /// Entschlüssele Entry
  Future<Entry> _decryptEntry(String encrypted, String key) async {
    final parts = encrypted.split('.');
    final encryptedData = EncryptedData(
      ciphertext: Uint8List.fromList(base64Decode(parts[0])),
      nonce: Uint8List.fromList(base64Decode(parts[1])),
      mac: Mac(base64Decode(parts[2])),
    );
    final keyBytes = SecretKey(utf8.encode(key).sublist(0, 32));
    final decryptedBytes = await _encryption.decrypt(encryptedData, keyBytes);
    final json = utf8.decode(decryptedBytes);
    return Entry.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }
  
  // ==================== CONNECTION MANAGEMENT ====================
  
  /// Verbinde zu einem Gerät
  Future<Socket> _connectToDevice(String deviceId) async {
    final device = _pairedDevices[deviceId];
    if (device == null) {
      throw Exception('Gerät nicht gefunden: $deviceId');
    }
    
    final socket = await Socket.connect(
      device.ipAddress,
      device.port,
      timeout: const Duration(seconds: 10),
    );
    
    _handleConnection(socket);
    
    return socket;
  }
  
  /// Handle Connection
  void _handleConnection(Socket socket) {
    socket.listen((data) async {
      try {
        final message = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
        final typeIndex = message['type'] as int?;
        if (typeIndex == null || typeIndex < 0 || typeIndex >= SyncMessageType.values.length) {
          assert(() { debugPrint('[LAN Sync] Unknown message type: $typeIndex'); return true; }());
          return;
        }
        final messageType = SyncMessageType.values[typeIndex];

        switch (messageType) {
          case SyncMessageType.pairingRequest:
            await _handlePairingRequest(socket, message);
            break;
          default:
            break;
        }
      } catch (e) {
        assert(() { debugPrint('[LAN Sync] Parse error: $e'); return true; }());
      }
    });

    socket.handleError((error) {
      assert(() { debugPrint('[LAN Sync] Connection error: $error'); return true; }());
      socket.destroy();
    });
  }
  
  /// Lese Nachricht von Socket
  Future<Map<String, dynamic>> _readMessage(Socket socket) async {
    final completer = Completer<Map<String, dynamic>>();

    late StreamSubscription subscription;
    subscription = socket.listen((data) {
      if (completer.isCompleted) return;
      try {
        final message = jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
        subscription.cancel();
        completer.complete(message);
      } catch (e) {
        subscription.cancel();
        completer.completeError(e);
      }
    }, onError: (Object e) {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(e);
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        subscription.cancel();
        throw TimeoutException('Keine Antwort erhalten');
      },
    );
  }
  
  // ==================== HELPERS ====================
  
  /// Hole lokale IP-Adresse
  Future<String> _getLocalIpAddress() async {
    for (final interface in await NetworkInterface.list()) {
      for (final addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
          return addr.address;
        }
      }
    }
    return '0.0.0.0';
  }
  
  /// Generiere Gerätename
  String _generateDeviceName() {
    final hostname = Platform.localHostname;
    return 'LifeSync ($hostname)';
  }
  
  /// Hole lokale Sync-Info
  Future<SyncInfo> _getLocalSyncInfo() async {
    final vault = await _storage.loadDefaultVault();
    final entryCount = await _storage.countEntries();
    
    return SyncInfo(
      deviceId: _thisDevice.id,
      lastSyncAt: DateTime.now(),
      entryCount: entryCount,
      vaultId: vault?.id ?? 0,
    );
  }
  
  /// Hole geänderte Einträge seit Datum
  Future<List<Entry>> _getChangedEntries(DateTime? since) async {
    // Implementierung für inkrementellen Sync
    return await _storage.getAllEntries(since: since);
  }
  
  /// Speichere gepaarte Geräte
  Future<void> _savePairedDevices() async {
    // Speichere in lokale Konfiguration
    // Implementierung mit SharedPreferences oder Isar
  }
  
  /// Dispose
  void dispose() {
    stopDiscovery();
    stopServer();
    
    for (final socket in _activeConnections.values) {
      socket.destroy();
    }
    _activeConnections.clear();
    
    _syncStatusController.close();
    _discoveredDevicesController.close();
    _syncProgressController.close();
  }
}

// ==================== DATA CLASSES ====================

/// Sync Device Info
class SyncDevice {
  final String id;
  final String name;
  final String platform;
  final String version;
  
  SyncDevice({
    required this.id,
    required this.name,
    required this.platform,
    required this.version,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'platform': platform,
    'version': version,
  };
  
  factory SyncDevice.fromJson(Map<String, dynamic> json) => SyncDevice(
    id: json['id'] as String,
    name: json['name'] as String,
    platform: json['platform'] as String,
    version: json['version'] as String,
  );
}

/// Discovered Device
class DiscoveredDevice {
  final String id;
  final String name;
  final String platform;
  final String ipAddress;
  final int port;
  final DateTime discoveredAt;
  final bool isPaired;
  
  DiscoveredDevice({
    required this.id,
    required this.name,
    required this.platform,
    required this.ipAddress,
    required this.port,
    required this.discoveredAt,
    required this.isPaired,
  });
}

/// Paired Device
class PairedDevice {
  final String id;
  final String name;
  final String platform;
  final String ipAddress;
  final int port;
  final DateTime pairedAt;
  final String encryptionKey;
  SyncInfo? lastSyncInfo;
  
  PairedDevice({
    required this.id,
    required this.name,
    required this.platform,
    required this.ipAddress,
    required this.port,
    required this.pairedAt,
    required this.encryptionKey,
    this.lastSyncInfo,
  });
}

/// Pairing Info
class PairingInfo {
  final String code;
  final String deviceId;
  final String deviceName;
  final DateTime expiresAt;
  final String encryptionKey;
  
  PairingInfo({
    required this.code,
    required this.deviceId,
    required this.deviceName,
    required this.expiresAt,
    required this.encryptionKey,
  });
}

/// Sync Info
class SyncInfo {
  final String deviceId;
  final DateTime lastSyncAt;
  final int entryCount;
  final int vaultId;
  
  SyncInfo({
    required this.deviceId,
    required this.lastSyncAt,
    required this.entryCount,
    required this.vaultId,
  });
  
  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'lastSyncAt': lastSyncAt.toIso8601String(),
    'entryCount': entryCount,
    'vaultId': vaultId,
  };
  
  factory SyncInfo.fromJson(Map<String, dynamic> json) => SyncInfo(
    deviceId: json['deviceId'] as String,
    lastSyncAt: DateTime.parse(json['lastSyncAt'] as String),
    entryCount: json['entryCount'] as int,
    vaultId: json['vaultId'] as int,
  );
}

/// Sync Status
enum SyncStatus {
  idle,
  discovering,
  paired,
  syncing,
  synced,
  error,
}

/// Sync Progress
class SyncProgress {
  final SyncPhase phase;
  final int current;
  final int total;
  
  SyncProgress({
    required this.phase,
    required this.current,
    required this.total,
  });
  
  double get progress => total > 0 ? current / total : 0;
}

/// Sync Phase
enum SyncPhase {
  metadata,
  entries,
  media,
  finalizing,
}

/// Discovery Message Type
enum DiscoveryMessageType {
  announcement,
  request,
  response,
}

/// Sync Message Type
enum SyncMessageType {
  pairingRequest,
  pairingResponse,
  syncMetadata,
  entryUpdate,
  entryDelete,
  mediaUpdate,
  mediaRequest,
  syncComplete,
}

/// Sync Message
class SyncMessage {
  final SyncMessageType type;
  final Map<String, dynamic> data;
  
  SyncMessage(this.type, this.data);
  
  Map<String, dynamic> toJson() => {
    'type': type.index,
    ...data,
  };
  
  factory SyncMessage.fromJson(Map<String, dynamic> json) => SyncMessage(
    SyncMessageType.values[json['type'] as int],
    Map<String, dynamic>.from(json)..remove('type'),
  );
}

/// Timeout Exception
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

/// Riverpod Provider
final lanSyncServiceProvider = StateProvider<LanSyncService?>((ref) {
  return null; // Wird in main.dart initialisiert
});
