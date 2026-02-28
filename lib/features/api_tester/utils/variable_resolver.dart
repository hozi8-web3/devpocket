class VariableResolver {
  /// Regular expression to match {{variable_name}}
  static final RegExp _varRegex = RegExp(r'\{\{(.*?)\}\}');

  /// Resolves all variables in a given string using the provided [variables] map.
  static String resolve(String? input, Map<String, String> variables) {
    if (input == null || input.isEmpty) return '';
    
    return input.replaceAllMapped(_varRegex, (match) {
      final key = match.group(1)?.trim() ?? '';
      return variables[key] ?? match.group(0)!; // Keep original if not found
    });
  }

  /// Resolves variables in a map of strings (e.g., Headers or Params).
  static Map<String, String> resolveMap(
      Map<String, String>? input, Map<String, String> variables) {
    if (input == null) return {};
    return input.map((key, value) => MapEntry(
          resolve(key, variables),
          resolve(value, variables),
        ));
  }
}
