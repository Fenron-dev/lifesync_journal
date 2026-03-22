import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/services/lan_sync_service.dart' hide lanSyncServiceProvider;
import '../../core/providers/app_provider.dart';

/// LAN Sync Screen - Geräte koppeln und synchronisieren
class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  SyncStatus _syncStatus = SyncStatus.idle;
  List<DiscoveredDevice> _discoveredDevices = [];
  List<PairedDevice> _pairedDevices = [];
  SyncProgress? _syncProgress;
  PairingInfo? _pairingInfo;
  String? _qrCodeData;
  
  StreamSubscription<SyncStatus>? _statusSubscription;
  StreamSubscription<List<DiscoveredDevice>>? _devicesSubscription;
  StreamSubscription<SyncProgress>? _progressSubscription;
  
  final _pairingCodeController = TextEditingController();
  bool _isDiscoveryActive = false;
  
  @override
  void initState() {
    super.initState();
    _setupListeners();
    _loadPairedDevices();
  }
  
  @override
  void dispose() {
    _statusSubscription?.cancel();
    _devicesSubscription?.cancel();
    _progressSubscription?.cancel();
    _pairingCodeController.dispose();
    super.dispose();
  }
  
  void _setupListeners() {
    final syncService = ref.read(lanSyncServiceProvider);
    if (syncService == null) return;
    
    _statusSubscription = syncService.syncStatus.listen((status) {
      setState(() => _syncStatus = status);
    });
    
    _devicesSubscription = syncService.discoveredDevices.listen((devices) {
      setState(() => _discoveredDevices = devices);
    });
    
    _progressSubscription = syncService.syncProgress.listen((progress) {
      setState(() => _syncProgress = progress);
    });
  }
  
  Future<void> _loadPairedDevices() async {
    // Lade gepaarte Geräte aus lokalem Speicher
    setState(() {
      // Demo-Daten für Preview
      _pairedDevices = [];
    });
  }
  
  Future<void> _startDiscovery() async {
    final syncService = ref.read(lanSyncServiceProvider);
    if (syncService == null) return;
    
    setState(() => _isDiscoveryActive = true);
    await syncService.startDiscovery();
    
    // Starte auch den Server für eingehende Verbindungen
    await syncService.startServer();
  }
  
  Future<void> _stopDiscovery() async {
    final syncService = ref.read(lanSyncServiceProvider);
    if (syncService == null) return;
    
    setState(() => _isDiscoveryActive = false);
    await syncService.stopDiscovery();
  }
  
  void _showPairingOptions() {
    final syncService = ref.read(lanSyncServiceProvider);
    if (syncService == null) return;
    
    _pairingInfo = syncService.generatePairingCode();
    _qrCodeData = syncService.generatePairingQrCode();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PairingBottomSheet(
        pairingInfo: _pairingInfo!,
        qrCodeData: _qrCodeData!,
        onPairWithCode: _pairWithCode,
      ),
    );
  }
  
  Future<void> _pairWithCode(String code) async {
    // In echter Implementierung würde hier die Device-ID übergeben
    // Für Demo-Zwecke zeigen wir nur den Ablauf
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pairing erfolgreich!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Future<void> _startSync(String deviceId) async {
    final syncService = ref.read(lanSyncServiceProvider);
    if (syncService == null) return;
    
    try {
      await syncService.startSync(deviceId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation abgeschlossen!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync fehlgeschlagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _unpairDevice(String deviceId) async {
    setState(() {
      _pairedDevices.removeWhere((d) => d.id == deviceId);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gerät entfernt'),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LAN Sync'),
        actions: [
          if (_isDiscoveryActive)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: _stopDiscovery,
              tooltip: 'Suche stoppen',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          _buildStatusCard(),
          
          const SizedBox(height: 24),
          
          // Gepaarte Geräte
          if (_pairedDevices.isNotEmpty) ...[
            Text(
              'Gepaarte Geräte',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...(_pairedDevices.map((device) => _PairedDeviceCard(
              device: device,
              onSync: () => _startSync(device.id),
              onUnpair: () => _unpairDevice(device.id),
              syncStatus: _syncStatus,
              syncProgress: _syncProgress,
            ))),
            const SizedBox(height: 24),
          ],
          
          // Gefundene Geräte
          Text(
            'Gefundene Geräte',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          
          if (_discoveredDevices.isEmpty)
            _buildEmptyDevicesState()
          else
            ...(_discoveredDevices
                .where((d) => !d.isPaired)
                .map((device) => _DiscoveredDeviceCard(
              device: device,
              onPair: () => _showPairingOptions(),
            ))),
          
          const SizedBox(height: 24),
          
          // Sync Info
          _buildSyncInfoCard(),
        ],
      ),
      
      // FAB für Discovery
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isDiscoveryActive ? _stopDiscovery : _startDiscovery,
        icon: Icon(_isDiscoveryActive ? Icons.stop : Icons.search),
        label: Text(_isDiscoveryActive ? 'Stoppen' : 'Geräte suchen'),
      ),
    );
  }
  
  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (_syncStatus) {
      case SyncStatus.idle:
        statusColor = Colors.grey;
        statusText = 'Bereit';
        statusIcon = Icons.cloud_off;
        break;
      case SyncStatus.discovering:
        statusColor = Colors.blue;
        statusText = 'Suche Geräte...';
        statusIcon = Icons.wifi_find;
        break;
      case SyncStatus.paired:
        statusColor = Colors.green;
        statusText = 'Gepaart';
        statusIcon = Icons.link;
        break;
      case SyncStatus.syncing:
        statusColor = Colors.orange;
        statusText = 'Synchronisiere...';
        statusIcon = Icons.sync;
        break;
      case SyncStatus.synced:
        statusColor = Colors.green;
        statusText = 'Synchronisiert';
        statusIcon = Icons.check_circle;
        break;
      case SyncStatus.error:
        statusColor = Colors.red;
        statusText = 'Fehler';
        statusIcon = Icons.error;
        break;
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(statusIcon, color: statusColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sync Status',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        statusText,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_syncStatus == SyncStatus.syncing && _syncProgress != null)
                  CircularProgressIndicator(
                    value: _syncProgress!.progress,
                  ),
              ],
            ),
            
            if (_syncProgress != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _syncProgress!.progress),
              const SizedBox(height: 8),
              Text(
                '${_syncProgress!.current} / ${_syncProgress!.total} Einträge',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyDevicesState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.devices_other,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _isDiscoveryActive 
                  ? 'Suche nach Geräten im WLAN...'
                  : 'Tippe auf "Geräte suchen" um Geräte im lokalen Netzwerk zu finden',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (_isDiscoveryActive) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSyncInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Wie funktioniert LAN Sync?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoStep(
              '1. Geräte koppeln',
              'Scanne den QR-Code oder gib den 6-stelligen Code ein',
            ),
            _buildInfoStep(
              '2. Automatische Verschlüsselung',
              'Alle Daten werden mit AES-256-GCM verschlüsselt übertragen',
            ),
            _buildInfoStep(
              '3. Konfliktlösung',
              'Bei gleichzeitigen Änderungen wird automatisch zusammengeführt',
            ),
            const SizedBox(height: 8),
            Text(
              '💡 Dein Journal bleibt zu 100% lokal - keine Cloud nötig!',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pairing Bottom Sheet
class _PairingBottomSheet extends StatelessWidget {
  final PairingInfo pairingInfo;
  final String qrCodeData;
  final Function(String) onPairWithCode;
  
  const _PairingBottomSheet({
    required this.pairingInfo,
    required this.qrCodeData,
    required this.onPairWithCode,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Gerät koppeln',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Scanne diesen QR-Code oder gib den Code ein',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: QrImageView(
              data: qrCodeData,
              version: QrVersions.auto,
              size: 200,
            ),
          ),
          const SizedBox(height: 16),
          
          // Pairing Code
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pairingInfo.code.split('').map((digit) => 
              Container(
                width: 40,
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    digit,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Gültig für 5 Minuten',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'oder',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 24),
          
          // Code eingeben
          TextField(
            decoration: InputDecoration(
              labelText: 'Pairing-Code eingeben',
              hintText: '6-stelliger Code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => onPairWithCode('123456'),
              ),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Paired Device Card
class _PairedDeviceCard extends StatelessWidget {
  final PairedDevice device;
  final VoidCallback onSync;
  final VoidCallback onUnpair;
  final SyncStatus syncStatus;
  final SyncProgress? syncProgress;
  
  const _PairedDeviceCard({
    required this.device,
    required this.onSync,
    required this.onUnpair,
    required this.syncStatus,
    this.syncProgress,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getPlatformColor(device.platform).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getPlatformIcon(device.platform),
                    color: _getPlatformColor(device.platform),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${device.platform} • ${device.ipAddress}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.sync),
                  onPressed: syncStatus == SyncStatus.syncing ? null : onSync,
                  tooltip: 'Jetzt synchronisieren',
                ),
                IconButton(
                  icon: const Icon(Icons.link_off),
                  onPressed: onUnpair,
                  tooltip: 'Kopplung aufheben',
                ),
              ],
            ),
            
            // Last Sync Info
            if (device.lastSyncInfo != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Letzte Sync: ${_formatLastSync(device.lastSyncInfo!.lastSyncAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${device.lastSyncInfo!.entryCount} Einträge',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return Icons.phone_iphone;
      case 'android':
        return Icons.phone_android;
      case 'macos':
        return Icons.laptop_mac;
      case 'windows':
        return Icons.laptop_windows;
      case 'linux':
        return Icons.laptop;
      default:
        return Icons.devices;
    }
  }
  
  Color _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
      case 'macos':
        return Colors.grey;
      case 'android':
        return Colors.green;
      case 'windows':
        return Colors.blue;
      case 'linux':
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }
  
  String _formatLastSync(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return 'gerade eben';
    if (diff.inMinutes < 60) return 'vor ${diff.inMinutes} Min.';
    if (diff.inHours < 24) return 'vor ${diff.inHours} Std.';
    return 'vor ${diff.inDays} Tagen';
  }
}

/// Discovered Device Card
class _DiscoveredDeviceCard extends StatelessWidget {
  final DiscoveredDevice device;
  final VoidCallback onPair;
  
  const _DiscoveredDeviceCard({
    required this.device,
    required this.onPair,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.devices,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(device.name),
        subtitle: Text('${device.platform} • ${device.ipAddress}'),
        trailing: ElevatedButton(
          onPressed: onPair,
          child: const Text('Koppeln'),
        ),
      ),
    );
  }
}
