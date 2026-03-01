import 'dart:convert';
import 'package:dio/dio.dart';

class NetworkServices {
  static final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    validateStatus: (_) => true,
  ));

  // --- Ping ---
  static Future<PingResult> ping(String host, {int count = 4}) async {
    final times = <int?>[];
    final cleanHost = host.replaceAll(RegExp(r'https?://'), '').split('/').first;

    for (int i = 0; i < count; i++) {
      try {
        final sw = Stopwatch()..start();
        await _dio.get('http://$cleanHost', options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ));
        sw.stop();
        times.add(sw.elapsedMilliseconds);
      } catch (e) {
        // Try HTTPS
        try {
          final sw = Stopwatch()..start();
          await _dio.get('https://$cleanHost', options: Options(
            sendTimeout: const Duration(seconds: 3),
            receiveTimeout: const Duration(seconds: 3),
          ));
          sw.stop();
          times.add(sw.elapsedMilliseconds);
        } catch (_) {
          times.add(null);
        }
      }
    }

    final successful = times.whereType<int>().toList();
    return PingResult(
      host: cleanHost,
      responseTimes: times,
      avgMs: successful.isEmpty ? null : successful.reduce((a, b) => a + b) ~/ successful.length,
      minMs: successful.isEmpty ? null : successful.reduce((a, b) => a < b ? a : b),
      maxMs: successful.isEmpty ? null : successful.reduce((a, b) => a > b ? a : b),
      packetLoss: (times.length - successful.length) / times.length,
    );
  }

  // --- DNS Lookup via DoH ---
  static Future<DnsResult> dnsLookup(String host, List<String> types) async {
    final cleanHost = host.replaceAll(RegExp(r'https?://'), '').split('/').first;
    final records = <String, List<String>>{};

    for (final type in types) {
      try {
        final response = await _dio.get(
          'https://dns.google/resolve',
          queryParameters: {'name': cleanHost, 'type': type},
          options: Options(headers: {'Accept': 'application/dns-json'}),
        );
        if (response.statusCode == 200) {
          final data = response.data is String ? jsonDecode(response.data as String) : response.data as Map<String, dynamic>;
          final answers = (data['Answer'] as List<dynamic>? ?? []);
          records[type] = answers.map((a) => (a as Map<String, dynamic>)['data'].toString()).toList();
        }
      } catch (_) {}
    }

    return DnsResult(host: cleanHost, records: records);
  }

  // --- SSL Certificate ---
  static Future<SslResult> checkSsl(String host) async {
    final cleanHost = host.replaceAll(RegExp(r'https?://'), '').split('/').first;
    try {
      // Use crt.sh API for certificate info
      final response = await _dio.get(
        'https://crt.sh/',
        queryParameters: {'q': cleanHost, 'output': 'json'},
      );

      final now = DateTime.now();
      if (response.statusCode == 200) {
        final data = response.data is String
            ? jsonDecode(response.data as String) as List<dynamic>
            : response.data as List<dynamic>;

        if (data.isNotEmpty) {
          final cert = data.first as Map<String, dynamic>;
          DateTime? notAfter;
          try {
            notAfter = DateTime.parse(cert['not_after'].toString().replaceAll(' ', 'T'));
          } catch (_) {}

          final daysLeft = notAfter?.difference(now).inDays;
          return SslResult(
            host: cleanHost,
            isValid: daysLeft != null && daysLeft > 0,
            isExpired: daysLeft != null && daysLeft <= 0,
            expiryDate: notAfter,
            daysRemaining: daysLeft,
            issuer: cert['issuer_name']?.toString() ?? 'Unknown',
            subject: cert['common_name']?.toString() ?? cleanHost,
            sans: [cleanHost],
          );
        }
      }
    } catch (_) {}

    return SslResult(
      host: cleanHost,
      isValid: false,
      isExpired: false,
      errorMessage: 'Could not retrieve SSL certificate information',
    );
  }

  // --- HTTP Headers ---
  static Future<HeadersResult> fetchHeaders(String url) async {
    if (!url.startsWith('http')) url = 'https://$url';
    try {
      final response = await _dio.head(url);
      final headers = <String, String>{};
      response.headers.forEach((k, v) => headers[k] = v.join(', '));
      return HeadersResult(url: url, headers: headers, statusCode: response.statusCode ?? 0);
    } catch (e) {
      try {
        final response = await _dio.get(url);
        final headers = <String, String>{};
        response.headers.forEach((k, v) => headers[k] = v.join(', '));
        return HeadersResult(url: url, headers: headers, statusCode: response.statusCode ?? 0);
      } catch (_) {
        return HeadersResult(url: url, headers: {}, statusCode: 0, error: e.toString());
      }
    }
  }

  // --- IP Lookup ---
  static Future<IpResult> lookupIp(String ip) async {
    final cleanIp = ip.trim().isEmpty ? '' : ip.trim();
    try {
      final url = cleanIp.isEmpty
          ? 'http://ip-api.com/json?fields=status,message,country,countryCode,regionName,city,isp,org,as,lat,lon,timezone,query'
          : 'http://ip-api.com/json/$cleanIp?fields=status,message,country,countryCode,regionName,city,isp,org,as,lat,lon,timezone,query';

      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data as String) : response.data as Map<String, dynamic>;
        if (data['status'] == 'success') {
          return IpResult(
            ip: data['query']?.toString() ?? '',
            country: data['country']?.toString(),
            countryCode: data['countryCode']?.toString(),
            region: data['regionName']?.toString(),
            city: data['city']?.toString(),
            isp: data['isp']?.toString(),
            org: data['org']?.toString(),
            asn: data['as']?.toString(),
            timezone: data['timezone']?.toString(),
            lat: (data['lat'] as num?)?.toDouble(),
            lon: (data['lon'] as num?)?.toDouble(),
          );
        }
      }
    } catch (_) {}
    return IpResult(ip: ip, error: 'Failed to lookup IP information');
  }
}

class PingResult {
  final String host;
  final List<int?> responseTimes;
  final int? avgMs, minMs, maxMs;
  final double packetLoss;

  const PingResult({
    required this.host,
    required this.responseTimes,
    this.avgMs, this.minMs, this.maxMs,
    required this.packetLoss,
  });
}

class DnsResult {
  final String host;
  final Map<String, List<String>> records;
  const DnsResult({required this.host, required this.records});
}

class SslResult {
  final String host;
  final bool isValid;
  final bool isExpired;
  final DateTime? expiryDate;
  final int? daysRemaining;
  final String? issuer;
  final String? subject;
  final List<String>? sans;
  final String? errorMessage;

  const SslResult({
    required this.host,
    required this.isValid,
    required this.isExpired,
    this.expiryDate,
    this.daysRemaining,
    this.issuer,
    this.subject,
    this.sans,
    this.errorMessage,
  });
}

class HeadersResult {
  final String url;
  final Map<String, String> headers;
  final int statusCode;
  final String? error;

  const HeadersResult({
    required this.url,
    required this.headers,
    required this.statusCode,
    this.error,
  });
}

class IpResult {
  final String ip;
  final String? country, countryCode, region, city, isp, org, asn, timezone;
  final double? lat, lon;
  final String? error;

  const IpResult({
    required this.ip,
    this.country, this.countryCode, this.region, this.city,
    this.isp, this.org, this.asn, this.timezone,
    this.lat, this.lon, this.error,
  });
}
