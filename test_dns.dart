// ignore_for_file: avoid_print
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
      validateStatus: (_) => true, connectTimeout: Duration(seconds: 3)));

  final providers = [
    'https://dns.adguard-dns.com/resolve',
    'https://dns.quad9.net:5053/dns-query', // sometimes JSON works here, or normal 443
    'https://doh.opendns.com/dns-query',
    'https://doh.mullvad.net/dns-query',
  ];

  for (var p in providers) {
    try {
      final response = await dio.get(
        p,
        queryParameters: {'name': 'google.com', 'type': 'A'},
        options: Options(headers: {'Accept': 'application/dns-json'}),
      );
      print('$p -> ${response.statusCode}');
      if (response.statusCode == 200) {
        print('  Data: ${response.data}');
      }
    } catch (e) {
      print('$p -> Error: $e');
    }
  }
}
