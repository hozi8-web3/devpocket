class Validators {
  Validators._();

  static String? requiredField(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  static String? url(String? v) {
    if (v == null || v.trim().isEmpty) return 'URL is required';
    final uri = Uri.tryParse(v.trim());
    if (uri == null || (!uri.hasScheme)) return 'Enter a valid URL';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return regex.hasMatch(v.trim()) ? null : 'Enter a valid email';
  }

  static String? json(String? v) {
    if (v == null || v.trim().isEmpty) return 'JSON is required';
    try {
      // Simple bracket matching
      var depth = 0;
      for (final c in v.split('')) {
        if (c == '{' || c == '[') depth++;
        if (c == '}' || c == ']') depth--;
        if (depth < 0) return 'Invalid JSON: unexpected closing bracket';
      }
      if (depth != 0) return 'Invalid JSON: unclosed brackets';
      return null;
    } catch (_) {
      return 'Invalid JSON';
    }
  }

  static String? port(String? v) {
    if (v == null || v.trim().isEmpty) return 'Port is required';
    final n = int.tryParse(v.trim());
    if (n == null || n < 1 || n > 65535) return 'Port must be 1–65535';
    return null;
  }

  static String? cronExpression(String v) {
    final parts = v.trim().split(RegExp(r'\s+'));
    if (parts.length != 5 && parts.length != 6) {
      return 'Cron must have 5 or 6 fields';
    }
    return null;
  }

  static bool isValidJson(String text) {
    if (text.trim().isEmpty) return false;
    try {
      var depth = 0;
      var inString = false;
      var escape = false;
      for (final c in text.runes) {
        final ch = String.fromCharCode(c);
        if (escape) { escape = false; continue; }
        if (ch == '\\' && inString) { escape = true; continue; }
        if (ch == '"') { inString = !inString; continue; }
        if (!inString) {
          if (ch == '{' || ch == '[') depth++;
          if (ch == '}' || ch == ']') { depth--; if (depth < 0) return false; }
        }
      }
      return depth == 0 && !inString;
    } catch (_) {
      return false;
    }
  }
}
