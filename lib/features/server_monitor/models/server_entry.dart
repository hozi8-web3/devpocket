import 'package:hive_flutter/hive_flutter.dart';

enum ServerStatus { unknown, up, down, degraded }

class ServerEntry {
  final String id;
  String name;
  String url;
  int intervalMinutes;
  bool enabled;
  ServerStatus status;
  int? lastResponseMs;
  DateTime? lastChecked;
  int? lastStatusCode;
  String? lastError;
  List<UptimeRecord> history;

  ServerEntry({
    required this.id,
    required this.name,
    required this.url,
    this.intervalMinutes = 5,
    this.enabled = true,
    this.status = ServerStatus.unknown,
    this.lastResponseMs,
    this.lastChecked,
    this.lastStatusCode,
    this.lastError,
    List<UptimeRecord>? history,
  }) : history = history ?? [];

  double get uptimePercent {
    if (history.isEmpty) return 100.0;
    final ups = history.where((r) => r.isUp).length;
    return ups / history.length * 100;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'intervalMinutes': intervalMinutes,
        'enabled': enabled,
        'status': status.index,
        'lastResponseMs': lastResponseMs,
        'lastChecked': lastChecked?.toIso8601String(),
        'lastStatusCode': lastStatusCode,
        'lastError': lastError,
        'history': history.map((r) => r.toJson()).toList(),
      };

  factory ServerEntry.fromJson(Map<String, dynamic> json) => ServerEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
        intervalMinutes: json['intervalMinutes'] as int? ?? 5,
        enabled: json['enabled'] as bool? ?? true,
        status: ServerStatus.values[json['status'] as int? ?? 0],
        lastResponseMs: json['lastResponseMs'] as int?,
        lastChecked: json['lastChecked'] != null
            ? DateTime.parse(json['lastChecked'] as String)
            : null,
        lastStatusCode: json['lastStatusCode'] as int?,
        lastError: json['lastError'] as String?,
        history: (json['history'] as List<dynamic>? ?? [])
            .map((r) => UptimeRecord.fromJson(r as Map<String, dynamic>))
            .toList(),
      );
}

class UptimeRecord {
  final DateTime timestamp;
  final bool isUp;
  final int? responseMs;
  final int? statusCode;

  const UptimeRecord({
    required this.timestamp,
    required this.isUp,
    this.responseMs,
    this.statusCode,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'isUp': isUp,
        'responseMs': responseMs,
        'statusCode': statusCode,
      };

  factory UptimeRecord.fromJson(Map<String, dynamic> json) => UptimeRecord(
        timestamp: DateTime.parse(json['timestamp'] as String),
        isUp: json['isUp'] as bool,
        responseMs: json['responseMs'] as int?,
        statusCode: json['statusCode'] as int?,
      );
}
