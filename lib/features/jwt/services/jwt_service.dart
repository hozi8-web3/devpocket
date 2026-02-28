import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class JwtService {
  JwtService._();

  static JwtDecodeResult? decode(String token) {
    try {
      final parts = token.trim().split('.');
      if (parts.length < 2) return null;

      final header = _decodeBase64Json(parts[0]);
      final payload = _decodeBase64Json(parts[1]);
      final signature = parts.length > 2 ? parts[2] : '';

      if (header == null || payload == null) return null;

      DateTime? expiry;
      bool isExpired = false;
      Duration? timeRemaining;
      DateTime? issuedAt;
      DateTime? notBefore;

      if (payload['exp'] != null) {
        expiry = DateTime.fromMillisecondsSinceEpoch(
            (payload['exp'] as num).toInt() * 1000);
        isExpired = DateTime.now().isAfter(expiry);
        if (!isExpired) {
          timeRemaining = expiry.difference(DateTime.now());
        }
      }
      if (payload['iat'] != null) {
        issuedAt = DateTime.fromMillisecondsSinceEpoch(
            (payload['iat'] as num).toInt() * 1000);
      }
      if (payload['nbf'] != null) {
        notBefore = DateTime.fromMillisecondsSinceEpoch(
            (payload['nbf'] as num).toInt() * 1000);
      }

      return JwtDecodeResult(
        header: header,
        payload: payload,
        signature: signature,
        expiry: expiry,
        isExpired: isExpired,
        timeRemaining: timeRemaining,
        issuedAt: issuedAt,
        notBefore: notBefore,
        algorithm: header['alg'] as String? ?? 'unknown',
        type: header['typ'] as String? ?? 'JWT',
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _decodeBase64Json(String part) {
    try {
      // Add padding
      final padded = part.padRight((part.length + 3) ~/ 4 * 4, '=');
      final decoded = base64Url.decode(padded);
      return jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static bool verifyHmacSignature(String token, String secret, String algorithm) {
    try {
      final parts = token.trim().split('.');
      if (parts.length != 3) return false;

      final signingInput = '${parts[0]}.${parts[1]}';
      final secretBytes = utf8.encode(secret);
      final inputBytes = utf8.encode(signingInput);

      Hmac hmac;
      switch (algorithm.toUpperCase()) {
        case 'HS256':
          hmac = Hmac(sha256, secretBytes);
          break;
        case 'HS384':
          hmac = Hmac(sha384, secretBytes);
          break;
        case 'HS512':
          hmac = Hmac(sha512, secretBytes);
          break;
        default:
          return false;
      }

      final digest = hmac.convert(inputBytes);
      final expectedSig = base64Url.encode(digest.bytes).replaceAll('=', '');
      return expectedSig == parts[2];
    } catch (_) {
      return false;
    }
  }

  static String generate({
    required Map<String, dynamic> payload,
    required String secret,
    String algorithm = 'HS256',
    int expiryHours = 24,
  }) {
    final header = {'alg': algorithm, 'typ': 'JWT'};

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final fullPayload = {
      ...payload,
      'iat': now,
      'exp': now + expiryHours * 3600,
    };

    final headerEncoded = _encodeBase64(jsonEncode(header));
    final payloadEncoded = _encodeBase64(jsonEncode(fullPayload));
    final signingInput = '$headerEncoded.$payloadEncoded';

    final secretBytes = utf8.encode(secret);
    final inputBytes = utf8.encode(signingInput);

    Hmac hmac;
    switch (algorithm) {
      case 'HS384':
        hmac = Hmac(sha384, secretBytes);
        break;
      case 'HS512':
        hmac = Hmac(sha512, secretBytes);
        break;
      default:
        hmac = Hmac(sha256, secretBytes);
    }

    final signature = base64Url
        .encode(hmac.convert(inputBytes).bytes)
        .replaceAll('=', '');
    return '$signingInput.$signature';
  }

  static String _encodeBase64(String input) {
    return base64Url.encode(utf8.encode(input)).replaceAll('=', '');
  }

  static String prettyJson(Map<String, dynamic> map) {
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}

class JwtDecodeResult {
  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
  final String signature;
  final DateTime? expiry;
  final bool isExpired;
  final Duration? timeRemaining;
  final DateTime? issuedAt;
  final DateTime? notBefore;
  final String algorithm;
  final String type;

  const JwtDecodeResult({
    required this.header,
    required this.payload,
    required this.signature,
    this.expiry,
    required this.isExpired,
    this.timeRemaining,
    this.issuedAt,
    this.notBefore,
    required this.algorithm,
    required this.type,
  });
}
