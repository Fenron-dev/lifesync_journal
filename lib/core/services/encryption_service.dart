import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Encryption Service - AES-256-GCM Verschlüsselung
/// 
/// Bietet sichere Verschlüsselung für sensible Daten:
/// - AES-256-GCM für symmetrische Verschlüsselung
/// - PBKDF2 für Schlüsselableitung aus Passwort
/// - Sichere Schlüsselspeicherung im RAM
class EncryptionService {
  static const _keyDerivationIterations = 100000;
  static const _keyLength = 32; // 256 bits
  static const _saltLength = 32;
  
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  
  // In-memory Schlüssel-Cache (wird nie auf Disk geschrieben)
  final Map<String, SecretKey> _keyCache = {};
  
  final _algorithm = AesGcm.with256bits();
  final _pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _keyDerivationIterations,
    bits: _keyLength * 8,
  );
  
  /// Generiere ein zufälliges Salt
  Future<Uint8List> generateSalt() async {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(_saltLength, (_) => random.nextInt(256)),
    );
  }
  
  /// Generiere ein zufälliges Nonce
  Future<List<int>> generateNonce() async {
    return _algorithm.newNonce();
  }
  
  /// Leite einen Schlüssel aus einem Passwort ab
  Future<SecretKey> deriveKeyFromPassword(
    String password,
    Uint8List salt,
  ) async {
    final passwordBytes = utf8.encode(password);
    return await _pbkdf2.deriveKey(
      secretKey: SecretKey(passwordBytes),
      nonce: salt,
    );
  }
  
  /// Verschlüssele Daten mit einem Schlüssel
  Future<EncryptedData> encrypt(
    Uint8List plaintext,
    SecretKey key, {
    List<int>? nonce,
  }) async {
    final actualNonce = nonce ?? await generateNonce();
    final secretBox = await _algorithm.encrypt(
      plaintext,
      secretKey: key,
      nonce: actualNonce,
    );

    return EncryptedData(
      ciphertext: Uint8List.fromList(secretBox.cipherText),
      nonce: Uint8List.fromList(secretBox.nonce),
      mac: secretBox.mac,
    );
  }
  
  /// Entschlüssele Daten mit einem Schlüssel
  Future<Uint8List> decrypt(
    EncryptedData encryptedData,
    SecretKey key,
  ) async {
    final secretBox = SecretBox(
      encryptedData.ciphertext,
      nonce: encryptedData.nonce,
      mac: encryptedData.mac,
    );
    
    final decrypted = await _algorithm.decrypt(
      secretBox,
      secretKey: key,
    );
    return Uint8List.fromList(decrypted);
  }
  
  /// Verschlüssele einen String
  Future<EncryptedString> encryptString(
    String plaintext,
    SecretKey key,
  ) async {
    final encrypted = await encrypt(
      Uint8List.fromList(utf8.encode(plaintext)),
      key,
    );
    
    return EncryptedString(
      ciphertext: base64Encode(encrypted.ciphertext),
      nonce: base64Encode(encrypted.nonce),
      mac: base64Encode(encrypted.mac.bytes),
    );
  }
  
  /// Entschlüssele einen String
  Future<String> decryptString(
    EncryptedString encryptedString,
    SecretKey key,
  ) async {
    final encrypted = EncryptedData(
      ciphertext: base64Decode(encryptedString.ciphertext),
      nonce: base64Decode(encryptedString.nonce),
      mac: Mac(base64Decode(encryptedString.mac)),
    );
    
    final decrypted = await decrypt(encrypted, key);
    return utf8.decode(decrypted);
  }
  
  /// Speichere einen Schlüssel sicher im RAM-Cache
  void cacheKey(String keyId, SecretKey key) {
    _keyCache[keyId] = key;
  }
  
  /// Hole einen Schlüssel aus dem Cache
  SecretKey? getCachedKey(String keyId) {
    return _keyCache[keyId];
  }
  
  /// Lösche einen Schlüssel aus dem Cache
  void clearCachedKey(String keyId) {
    _keyCache.remove(keyId);
  }
  
  /// Lösche alle Schlüssel aus dem Cache
  void clearAllCachedKeys() {
    _keyCache.clear();
  }
  
  /// Speichere eine verschlüsselte Referenz sicher
  Future<void> storeSecureReference(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }
  
  /// Hole eine verschlüsselte Referenz
  Future<String?> getSecureReference(String key) async {
    return await _secureStorage.read(key: key);
  }
  
  /// Lösche eine verschlüsselte Referenz
  Future<void> deleteSecureReference(String key) async {
    await _secureStorage.delete(key: key);
  }
  
  /// Prüfe ob ein Schlüssel existiert
  Future<bool> hasSecureReference(String key) async {
    return await _secureStorage.containsKey(key: key);
  }
}

/// Verschlüsselte Daten (Bytes)
class EncryptedData {
  final Uint8List ciphertext;
  final Uint8List nonce;
  final Mac mac;
  
  EncryptedData({
    required this.ciphertext,
    required this.nonce,
    required this.mac,
  });
  
  /// Serialisiere zu JSON
  Map<String, dynamic> toJson() => {
    'ciphertext': base64Encode(ciphertext),
    'nonce': base64Encode(nonce),
    'mac': base64Encode(mac.bytes),
  };
  
  /// Deserialisiere von JSON
  factory EncryptedData.fromJson(Map<String, dynamic> json) {
    return EncryptedData(
      ciphertext: base64Decode(json['ciphertext']),
      nonce: base64Decode(json['nonce']),
      mac: Mac(base64Decode(json['mac'])),
    );
  }
}

/// Verschlüsselter String (Base64-kodiert)
class EncryptedString {
  final String ciphertext;
  final String nonce;
  final String mac;
  
  EncryptedString({
    required this.ciphertext,
    required this.nonce,
    required this.mac,
  });
  
  /// Serialisiere zu JSON
  Map<String, dynamic> toJson() => {
    'ciphertext': ciphertext,
    'nonce': nonce,
    'mac': mac,
  };
  
  /// Deserialisiere von JSON
  factory EncryptedString.fromJson(Map<String, dynamic> json) {
    return EncryptedString(
      ciphertext: json['ciphertext'],
      nonce: json['nonce'],
      mac: json['mac'],
    );
  }
  
  /// Gesamtlänge des verschlüsselten Strings
  int get totalLength => ciphertext.length + nonce.length + mac.length + 2; // +2 für separators
}

/// Riverpod Provider
final encryptionServiceProvider = StateProvider<EncryptionService?>((ref) {
  return null; // Wird in main.dart initialisiert
});
