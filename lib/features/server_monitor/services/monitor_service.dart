import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/server_entry.dart';

class MonitorService {
  static const _boxName = 'server_monitor';

  static Future<Box<String>> get _box async => Hive.openBox<String>(_boxName);

  static Future<List<ServerEntry>> loadAll() async {
    final box = await _box;
    return box.values
        .map((v) {
          try {
            return ServerEntry.fromJson(jsonDecode(v) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<ServerEntry>()
        .toList();
  }

  static Future<void> save(ServerEntry server) async {
    final box = await _box;
    await box.put(server.id, jsonEncode(server.toJson()));
  }

  static Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  static Future<ServerEntry> checkNow(ServerEntry server) async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (_) => true,
    ));

    String url = server.url;
    if (!url.startsWith('http')) url = 'https://$url';

    try {
      final sw = Stopwatch()..start();
      final response = await dio.get(url);
      sw.stop();

      final isUp = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 400;

      server.status = isUp ? ServerStatus.up : ServerStatus.degraded;
      server.lastResponseMs = sw.elapsedMilliseconds;
      server.lastChecked = DateTime.now();
      server.lastStatusCode = response.statusCode;
      server.lastError = isUp ? null : 'HTTP ${response.statusCode}';
    } on DioException catch (e) {
      server.status = ServerStatus.down;
      server.lastChecked = DateTime.now();
      server.lastResponseMs = null;
      server.lastStatusCode = null;
      server.lastError = e.type == DioExceptionType.connectionTimeout
          ? 'Connection timeout'
          : 'Connection failed';
    } catch (e) {
      server.status = ServerStatus.down;
      server.lastChecked = DateTime.now();
      server.lastError = e.toString();
    }

    // Add to history (keep last 100)
    server.history.add(UptimeRecord(
      timestamp: server.lastChecked!,
      isUp: server.status == ServerStatus.up,
      responseMs: server.lastResponseMs,
      statusCode: server.lastStatusCode,
    ));
    if (server.history.length > 100) {
      server.history.removeAt(0);
    }

    await save(server);
    return server;
  }
}
