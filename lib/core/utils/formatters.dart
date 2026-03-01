import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String fileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)}MB';
  }

  static String duration(Duration d) {
    if (d.inMilliseconds < 1000) return '${d.inMilliseconds}ms';
    return '${d.inSeconds}s ${d.inMilliseconds % 1000}ms';
  }

  static String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  static String dateTime(DateTime dt) =>
      DateFormat('MMM d, yyyy HH:mm').format(dt);

  static String date(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  static String utcDateTime(DateTime dt) =>
      '${DateFormat('yyyy-MM-dd HH:mm:ss').format(dt.toUtc())} UTC';

  static String percentage(double v) => '${(v * 100).toStringAsFixed(1)}%';

  static String uptime(double v) {
    final pct = v * 100;
    return '${pct.toStringAsFixed(2)}%';
  }

  static String truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}…' : s;

  static String camelToWords(String s) {
    return s.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (m) => ' ${m.group(0)}',
    ).trim();
  }

  static String snakeToTitle(String s) {
    return s.split('_').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}
