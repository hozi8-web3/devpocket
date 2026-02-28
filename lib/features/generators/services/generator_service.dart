import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

class GeneratorService {
  GeneratorService._();
  static final _random = Random.secure();

  // --- UUID ---
  static String generateUuid() => const Uuid().v4();

  static List<String> generateUuids(int count) =>
      List.generate(count, (_) => const Uuid().v4());

  // --- Password ---
  static const _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _lower = 'abcdefghjkmnpqrstuvwxyz';
  static const _digits = '23456789';
  static const _symbols = r'!@#$%^&*()-_=+[]{}|;:,.<>?';
  static const _ambiguous = r'lO0oI1';

  static String generatePassword({
    required int length,
    bool useUpper = true,
    bool useLower = true,
    bool useDigits = true,
    bool useSymbols = true,
    bool excludeAmbiguous = false,
  }) {
    var charset = '';
    if (useLower) charset += excludeAmbiguous ? _lower : _lower + 'lio';
    if (useUpper) charset += excludeAmbiguous ? _upper : _upper + 'IO';
    if (useDigits) charset += excludeAmbiguous ? _digits : _digits + '01';
    if (useSymbols) charset += _symbols;
    if (charset.isEmpty) charset = _lower;

    return List.generate(
        length, (_) => charset[_random.nextInt(charset.length)]).join();
  }

  static PasswordStrength getStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*()\-_=+\[\]{}|;:,.<>?]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.fair;
    if (score <= 6) return PasswordStrength.strong;
    return PasswordStrength.veryStrong;
  }

  // --- Hash ---
  static String hash(String input, HashAlgorithm algorithm, {bool uppercase = false}) {
    final bytes = utf8.encode(input);
    String result;
    switch (algorithm) {
      case HashAlgorithm.md5:
        result = md5.convert(bytes).toString();
        break;
      case HashAlgorithm.sha1:
        result = sha1.convert(bytes).toString();
        break;
      case HashAlgorithm.sha256:
        result = sha256.convert(bytes).toString();
        break;
      case HashAlgorithm.sha384:
        result = sha384.convert(bytes).toString();
        break;
      case HashAlgorithm.sha512:
        result = sha512.convert(bytes).toString();
        break;
    }
    return uppercase ? result.toUpperCase() : result;
  }

  // --- HMAC ---
  static String hmac(String message, String key, HashAlgorithm algorithm) {
    final keyBytes = utf8.encode(key);
    final msgBytes = utf8.encode(message);
    Hmac hmacHash;
    switch (algorithm) {
      case HashAlgorithm.md5:
        hmacHash = Hmac(md5, keyBytes);
        break;
      case HashAlgorithm.sha1:
        hmacHash = Hmac(sha1, keyBytes);
        break;
      case HashAlgorithm.sha256:
        hmacHash = Hmac(sha256, keyBytes);
        break;
      case HashAlgorithm.sha384:
        hmacHash = Hmac(sha384, keyBytes);
        break;
      case HashAlgorithm.sha512:
        hmacHash = Hmac(sha512, keyBytes);
        break;
    }
    return hmacHash.convert(msgBytes).toString();
  }

  // --- Random String ---
  static const _charsets = {
    'alphanumeric': 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
    'alpha': 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
    'numeric': '0123456789',
    'hex': '0123456789abcdef',
  };

  static String randomString(int length, String charset, [String? custom]) {
    final cs = charset == 'custom' ? (custom ?? 'abc') : (_charsets[charset] ?? _charsets['alphanumeric']!);
    return List.generate(length, (_) => cs[_random.nextInt(cs.length)]).join();
  }
}

enum PasswordStrength { weak, fair, strong, veryStrong }
enum HashAlgorithm { md5, sha1, sha256, sha384, sha512 }
