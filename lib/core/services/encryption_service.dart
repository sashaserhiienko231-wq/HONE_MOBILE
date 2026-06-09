import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Local encryption helpers for cloud backup payloads.
class EncryptionService {
  static const String _keySeed = 'hone_mobile_backup_key_v1';

  static List<int> _keyBytes() => sha256.convert(utf8.encode(_keySeed)).bytes;

  /// Encrypts [plainText] to a base64 payload.
  static Future<String> encrypt(String plainText) async {
    final bytes = utf8.encode(plainText);
    final key = _keyBytes();
    final out = List<int>.generate(
      bytes.length,
      (i) => bytes[i] ^ key[i % key.length],
    );
    return base64Encode(out);
  }

  /// Decrypts a base64 payload produced by [encrypt].
  static Future<String> decrypt(String encryptedBase64) async {
    final combined = base64Decode(encryptedBase64);
    final key = _keyBytes();
    final out = List<int>.generate(
      combined.length,
      (i) => combined[i] ^ key[i % key.length],
    );
    return utf8.decode(out);
  }
}
