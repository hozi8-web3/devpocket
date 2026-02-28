class RegexPattern {
  final String name;
  final String pattern;
  final String description;
  final String example;
  final String category;

  const RegexPattern({
    required this.name,
    required this.pattern,
    required this.description,
    required this.example,
    required this.category,
  });
}

const List<RegexPattern> builtInRegexPatterns = [
  // Validation
  RegexPattern(
    name: 'Email',
    pattern: r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    description: 'Validates an email address',
    example: 'user@example.com',
    category: 'Validation',
  ),
  RegexPattern(
    name: 'URL (HTTP/HTTPS)',
    pattern: r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&\/=]*)',
    description: 'Matches HTTP and HTTPS URLs',
    example: 'https://example.com/path?query=1',
    category: 'Validation',
  ),
  RegexPattern(
    name: 'IPv4 Address',
    pattern: r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$',
    description: 'Validates an IPv4 address',
    example: '192.168.1.1',
    category: 'Validation',
  ),
  RegexPattern(
    name: 'IPv6 Address',
    pattern: r'^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4})$',
    description: 'Validates an IPv6 address',
    example: '2001:0db8:85a3:0000:0000:8a2e:0370:7334',
    category: 'Validation',
  ),
  RegexPattern(
    name: 'Phone (International)',
    pattern: r'^\+?[1-9]\d{1,14}$',
    description: 'Validates international phone numbers (E.164)',
    example: '+14155552671',
    category: 'Validation',
  ),
  RegexPattern(
    name: 'US Phone',
    pattern: r'^\(?\d{3}\)?[-.\s]\d{3}[-.\s]\d{4}$',
    description: 'US phone number in common formats',
    example: '(555) 123-4567',
    category: 'Validation',
  ),
  RegexPattern(
    name: 'Credit Card',
    pattern: r'^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11})$',
    description: 'Matches Visa, MC, Amex, Discover',
    example: '4111111111111111',
    category: 'Validation',
  ),
  RegexPattern(
    name: 'Strong Password',
    pattern: r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    description: 'Min 8 chars with uppercase, lowercase, number, symbol',
    example: 'P@ssw0rd!',
    category: 'Validation',
  ),

  // Date & Time
  RegexPattern(
    name: 'Date (YYYY-MM-DD)',
    pattern: r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$',
    description: 'ISO 8601 date format',
    example: '2024-01-15',
    category: 'Date & Time',
  ),
  RegexPattern(
    name: 'Date (MM/DD/YYYY)',
    pattern: r'^(0[1-9]|1[0-2])\/(0[1-9]|[12]\d|3[01])\/\d{4}$',
    description: 'US date format',
    example: '01/15/2024',
    category: 'Date & Time',
  ),
  RegexPattern(
    name: 'Time (HH:MM)',
    pattern: r'^(0?[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$',
    description: '24-hour time format',
    example: '14:30',
    category: 'Date & Time',
  ),
  RegexPattern(
    name: 'ISO 8601 DateTime',
    pattern: r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:\d{2})$',
    description: 'Full ISO 8601 datetime with timezone',
    example: '2024-01-15T14:30:00Z',
    category: 'Date & Time',
  ),

  // Identifiers
  RegexPattern(
    name: 'UUID v4',
    pattern: r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    description: 'UUID version 4 format',
    example: '550e8400-e29b-41d4-a716-446655440000',
    category: 'Identifiers',
  ),
  RegexPattern(
    name: 'Hex Color',
    pattern: r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$',
    description: 'CSS hex color code',
    example: '#6C63FF',
    category: 'Identifiers',
  ),
  RegexPattern(
    name: 'MAC Address',
    pattern: r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$',
    description: 'Network MAC address',
    example: '00:1A:2B:3C:4D:5E',
    category: 'Identifiers',
  ),
  RegexPattern(
    name: 'Slug',
    pattern: r'^[a-z0-9]+(?:-[a-z0-9]+)*$',
    description: 'URL-friendly slug',
    example: 'my-article-title',
    category: 'Identifiers',
  ),
  RegexPattern(
    name: 'JWT',
    pattern: r'^[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+\/=]*$',
    description: 'JSON Web Token format',
    example: 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U',
    category: 'Identifiers',
  ),

  // Web
  RegexPattern(
    name: 'HTML Tag',
    pattern: r'<([a-zA-Z][a-zA-Z0-9]*)\b[^>]*>(.*?)<\/\1>',
    description: 'Matches HTML tags with content',
    example: '<div class="foo">content</div>',
    category: 'Web',
  ),
  RegexPattern(
    name: 'Query String Param',
    pattern: r'[?&]([^&=]+)=([^&]*)',
    description: 'Matches key=value URL parameters',
    example: '?name=John&age=30',
    category: 'Web',
  ),
  RegexPattern(
    name: 'Domain Name',
    pattern: r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$',
    description: 'Valid domain name',
    example: 'sub.example.com',
    category: 'Web',
  ),
];
