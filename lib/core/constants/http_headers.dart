class HttpHeaderEntry {
  final String name;
  final String type; // 'request', 'response', 'both'
  final String description;
  final String example;

  const HttpHeaderEntry({
    required this.name,
    required this.type,
    required this.description,
    required this.example,
  });
}

const List<HttpHeaderEntry> httpHeaders = [
  // Request Headers
  HttpHeaderEntry(name: 'Accept', type: 'request', description: 'Media types client can process.', example: 'Accept: application/json'),
  HttpHeaderEntry(name: 'Accept-Encoding', type: 'request', description: 'Content encodings acceptable to client.', example: 'Accept-Encoding: gzip, deflate, br'),
  HttpHeaderEntry(name: 'Accept-Language', type: 'request', description: 'Preferred languages for response.', example: 'Accept-Language: en-US,en;q=0.9'),
  HttpHeaderEntry(name: 'Authorization', type: 'request', description: 'Credentials for HTTP authentication.', example: 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...'),
  HttpHeaderEntry(name: 'Cache-Control', type: 'both', description: 'Directives for caching mechanisms.', example: 'Cache-Control: no-cache, no-store'),
  HttpHeaderEntry(name: 'Connection', type: 'both', description: 'Control options for the connection.', example: 'Connection: keep-alive'),
  HttpHeaderEntry(name: 'Content-Length', type: 'both', description: 'Size of the request/response body in bytes.', example: 'Content-Length: 1024'),
  HttpHeaderEntry(name: 'Content-Type', type: 'both', description: 'Media type of the request/response body.', example: 'Content-Type: application/json; charset=utf-8'),
  HttpHeaderEntry(name: 'Cookie', type: 'request', description: 'HTTP cookies sent to the server.', example: 'Cookie: session_id=abc123; user=john'),
  HttpHeaderEntry(name: 'Host', type: 'request', description: 'Domain name of the server.', example: 'Host: api.example.com'),
  HttpHeaderEntry(name: 'If-Match', type: 'request', description: 'ETag value for conditional requests.', example: 'If-Match: "etag-value"'),
  HttpHeaderEntry(name: 'If-Modified-Since', type: 'request', description: 'Only respond if modified after this date.', example: 'If-Modified-Since: Wed, 21 Oct 2023 07:28:00 GMT'),
  HttpHeaderEntry(name: 'If-None-Match', type: 'request', description: 'Return 304 if ETag matches.', example: 'If-None-Match: "etag-value"'),
  HttpHeaderEntry(name: 'Origin', type: 'request', description: 'Origin of a cross-origin request.', example: 'Origin: https://example.com'),
  HttpHeaderEntry(name: 'Referer', type: 'request', description: 'Address of the previous web page.', example: 'Referer: https://example.com/page'),
  HttpHeaderEntry(name: 'User-Agent', type: 'request', description: 'Software acting on behalf of the user.', example: 'User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 17_0)'),
  HttpHeaderEntry(name: 'X-API-Key', type: 'request', description: 'API key for authentication.', example: 'X-API-Key: your-api-key-here'),
  HttpHeaderEntry(name: 'X-Request-ID', type: 'both', description: 'Unique identifier for request tracing.', example: 'X-Request-ID: f7a9b302-c1d4-4e6f'),
  HttpHeaderEntry(name: 'X-Forwarded-For', type: 'request', description: 'IP address of client through proxy.', example: 'X-Forwarded-For: 203.0.113.195, 70.41.3.18'),
  // Response Headers
  HttpHeaderEntry(name: 'Access-Control-Allow-Origin', type: 'response', description: 'Allowed origins for CORS.', example: 'Access-Control-Allow-Origin: *'),
  HttpHeaderEntry(name: 'Access-Control-Allow-Methods', type: 'response', description: 'Allowed HTTP methods for CORS.', example: 'Access-Control-Allow-Methods: GET, POST, PUT, DELETE'),
  HttpHeaderEntry(name: 'Access-Control-Allow-Headers', type: 'response', description: 'Allowed headers for CORS.', example: 'Access-Control-Allow-Headers: Content-Type, Authorization'),
  HttpHeaderEntry(name: 'Content-Encoding', type: 'response', description: 'Compression used on the response body.', example: 'Content-Encoding: gzip'),
  HttpHeaderEntry(name: 'Content-Language', type: 'response', description: 'Language of the response content.', example: 'Content-Language: en-US'),
  HttpHeaderEntry(name: 'Content-Security-Policy', type: 'response', description: 'Controls resources the page can load.', example: "Content-Security-Policy: default-src 'self'"),
  HttpHeaderEntry(name: 'ETag', type: 'response', description: 'Identifier for a specific version of a resource.', example: 'ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"'),
  HttpHeaderEntry(name: 'Location', type: 'response', description: 'URL to redirect to for 3xx or 201 responses.', example: 'Location: https://www.example.com/new-location'),
  HttpHeaderEntry(name: 'Retry-After', type: 'response', description: 'How long to wait before retrying.', example: 'Retry-After: 120'),
  HttpHeaderEntry(name: 'Server', type: 'response', description: 'Software used by the server.', example: 'Server: nginx/1.18.0'),
  HttpHeaderEntry(name: 'Set-Cookie', type: 'response', description: 'Send a cookie to the client.', example: 'Set-Cookie: sessionId=abc123; HttpOnly; Secure'),
  HttpHeaderEntry(name: 'Strict-Transport-Security', type: 'response', description: 'Force HTTPS (HSTS).', example: 'Strict-Transport-Security: max-age=31536000; includeSubDomains'),
  HttpHeaderEntry(name: 'Vary', type: 'response', description: 'Which request headers influenced the response.', example: 'Vary: Accept-Encoding, Accept-Language'),
  HttpHeaderEntry(name: 'WWW-Authenticate', type: 'response', description: 'Authentication method for 401 responses.', example: 'WWW-Authenticate: Bearer realm="example"'),
  HttpHeaderEntry(name: 'X-Content-Type-Options', type: 'response', description: 'Prevents MIME-type sniffing.', example: 'X-Content-Type-Options: nosniff'),
  HttpHeaderEntry(name: 'X-Frame-Options', type: 'response', description: 'Controls iframe embedding.', example: 'X-Frame-Options: SAMEORIGIN'),
  HttpHeaderEntry(name: 'X-XSS-Protection', type: 'response', description: 'Cross-site scripting filter (legacy).', example: 'X-XSS-Protection: 1; mode=block'),
  HttpHeaderEntry(name: 'X-RateLimit-Limit', type: 'response', description: 'Maximum number of requests allowed.', example: 'X-RateLimit-Limit: 1000'),
  HttpHeaderEntry(name: 'X-RateLimit-Remaining', type: 'response', description: 'Remaining requests in time window.', example: 'X-RateLimit-Remaining: 732'),
  HttpHeaderEntry(name: 'X-RateLimit-Reset', type: 'response', description: 'Unix timestamp when limit resets.', example: 'X-RateLimit-Reset: 1698451200'),
];

// Security headers that should be present
const List<String> securityHeaders = [
  'Strict-Transport-Security',
  'Content-Security-Policy',
  'X-Content-Type-Options',
  'X-Frame-Options',
  'X-XSS-Protection',
  'Referrer-Policy',
];
