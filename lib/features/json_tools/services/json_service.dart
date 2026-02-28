import 'dart:convert';
import 'package:yaml/yaml.dart';

class JsonService {
  JsonService._();

  static String format(String input) {
    final decoded = jsonDecode(input);
    return const JsonEncoder.withIndent('  ').convert(decoded);
  }

  static String minify(String input) {
    final decoded = jsonDecode(input);
    return jsonEncode(decoded);
  }

  static JsonValidationResult validate(String input) {
    try {
      jsonDecode(input);
      return JsonValidationResult(isValid: true);
    } on FormatException catch (e) {
      // Parse position from error message
      int? line, column;
      final match = RegExp(r'line (\d+), column (\d+)').firstMatch(e.message);
      if (match != null) {
        line = int.tryParse(match.group(1) ?? '');
        column = int.tryParse(match.group(2) ?? '');
      }
      return JsonValidationResult(
        isValid: false,
        error: e.message,
        line: line,
        column: column,
      );
    }
  }

  static String toYaml(String jsonInput) {
    final decoded = jsonDecode(jsonInput);
    return _mapToYaml(decoded, 0);
  }

  static String _mapToYaml(dynamic value, int indent) {
    final pad = '  ' * indent;
    if (value is Map) {
      final sb = StringBuffer();
      value.forEach((k, v) {
        if (v is Map || v is List) {
          sb.writeln('$pad$k:');
          sb.write(_mapToYaml(v, indent + 1));
        } else {
          sb.writeln('$pad$k: ${_yamlValue(v)}');
        }
      });
      return sb.toString();
    } else if (value is List) {
      final sb = StringBuffer();
      for (final item in value) {
        if (item is Map || item is List) {
          sb.writeln('$pad-');
          sb.write(_mapToYaml(item, indent + 1));
        } else {
          sb.writeln('$pad- ${_yamlValue(item)}');
        }
      }
      return sb.toString();
    }
    return '$pad${_yamlValue(value)}\n';
  }

  static String _yamlValue(dynamic v) {
    if (v == null) return 'null';
    if (v is bool || v is num) return v.toString();
    final s = v.toString();
    if (s.contains(':') || s.contains('#') || s.isEmpty || s == 'true' || s == 'false') {
      return '"$s"';
    }
    return s;
  }

  static List<JsonDiffEntry> diff(String json1, String json2) {
    try {
      final a = jsonDecode(json1);
      final b = jsonDecode(json2);
      final result = <JsonDiffEntry>[];
      _diffObjects(a, b, '', result);
      return result;
    } catch (_) {
      return [JsonDiffEntry(key: 'error', type: DiffType.unchanged, value: 'Invalid JSON')];
    }
  }

  static void _diffObjects(
      dynamic a, dynamic b, String path, List<JsonDiffEntry> result) {
    if (a is Map && b is Map) {
      final allKeys = {...a.keys, ...b.keys};
      for (final key in allKeys) {
        final fullKey = path.isEmpty ? key.toString() : '$path.$key';
        if (!a.containsKey(key)) {
          result.add(JsonDiffEntry(key: fullKey, type: DiffType.added, value: jsonEncode(b[key])));
        } else if (!b.containsKey(key)) {
          result.add(JsonDiffEntry(key: fullKey, type: DiffType.removed, value: jsonEncode(a[key])));
        } else if (jsonEncode(a[key]) != jsonEncode(b[key])) {
          _diffObjects(a[key], b[key], fullKey, result);
        }
      }
    } else {
      final aStr = jsonEncode(a);
      final bStr = jsonEncode(b);
      if (aStr != bStr) {
        result.add(JsonDiffEntry(key: path, type: DiffType.changed, value: bStr, oldValue: aStr));
      }
    }
  }

  static dynamic jsonPathQuery(String json, String path) {
    try {
      dynamic data = jsonDecode(json);
      // Remove leading $
      final segments = path.replaceFirst(r'$', '').split(RegExp(r'\.|\[|\]')).where((s) => s.isNotEmpty).toList();
      for (final seg in segments) {
        final idx = int.tryParse(seg);
        if (idx != null && data is List) {
          data = data[idx];
        } else if (data is Map) {
          data = data[seg];
        } else {
          return null;
        }
      }
      return data;
    } catch (_) {
      return null;
    }
  }
}

class JsonValidationResult {
  final bool isValid;
  final String? error;
  final int? line;
  final int? column;

  const JsonValidationResult({required this.isValid, this.error, this.line, this.column});
}

class JsonDiffEntry {
  final String key;
  final DiffType type;
  final String value;
  final String? oldValue;

  const JsonDiffEntry({
    required this.key,
    required this.type,
    required this.value,
    this.oldValue,
  });
}

enum DiffType { added, removed, changed, unchanged }
