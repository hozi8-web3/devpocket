class HttpStatusCode {
  final int code;
  final String name;
  final String description;
  final String whenToUse;

  const HttpStatusCode({
    required this.code,
    required this.name,
    required this.description,
    required this.whenToUse,
  });
}

const List<HttpStatusCode> httpStatusCodes = [
  // 1xx Informational
  HttpStatusCode(code: 100, name: 'Continue', description: 'The server has received the request headers and the client should proceed to send the request body.', whenToUse: 'Used in large request bodies with Expect: 100-continue header.'),
  HttpStatusCode(code: 101, name: 'Switching Protocols', description: 'The requester has asked the server to switch protocols.', whenToUse: 'Used when upgrading from HTTP to WebSocket.'),
  HttpStatusCode(code: 102, name: 'Processing', description: 'The server has received and is processing the request, but no response is available yet.', whenToUse: 'WebDAV long-running operations.'),
  HttpStatusCode(code: 103, name: 'Early Hints', description: 'Preload resources while server is still preparing a response.', whenToUse: 'Used with Link headers to preload resources.'),

  // 2xx Success
  HttpStatusCode(code: 200, name: 'OK', description: 'The request has succeeded. The meaning of the response depends on the request method.', whenToUse: 'Standard success response for GET, POST, PUT, PATCH requests.'),
  HttpStatusCode(code: 201, name: 'Created', description: 'The request has been fulfilled and resulted in a new resource being created.', whenToUse: 'Returned after a successful POST that creates a resource.'),
  HttpStatusCode(code: 202, name: 'Accepted', description: 'The request has been accepted for processing, but the processing has not been completed.', whenToUse: 'Async operations, job queues.'),
  HttpStatusCode(code: 203, name: 'Non-Authoritative Information', description: 'The server is a transforming proxy that received a 200 from the origin.', whenToUse: 'Proxied responses with modified headers.'),
  HttpStatusCode(code: 204, name: 'No Content', description: 'The server successfully processed the request and is not returning any content.', whenToUse: 'DELETE requests, PUT updates with no body response.'),
  HttpStatusCode(code: 205, name: 'Reset Content', description: 'The server successfully processed the request, asks the client to reset the document view.', whenToUse: 'After form submission, tell client to clear form.'),
  HttpStatusCode(code: 206, name: 'Partial Content', description: 'The server is delivering only part of the resource due to a range header sent by the client.', whenToUse: 'Resumable downloads, video streaming.'),
  HttpStatusCode(code: 207, name: 'Multi-Status', description: 'The message body contains XML with multiple response codes.', whenToUse: 'WebDAV operations affecting multiple resources.'),
  HttpStatusCode(code: 208, name: 'Already Reported', description: 'The results of a DAV binding have already been enumerated in a previous reply.', whenToUse: 'WebDAV propfind requests.'),
  HttpStatusCode(code: 226, name: 'IM Used', description: 'The server has fulfilled a GET request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.', whenToUse: 'Delta encoding responses.'),

  // 3xx Redirection
  HttpStatusCode(code: 300, name: 'Multiple Choices', description: 'There are multiple options for the resource from which the client may choose.', whenToUse: 'Content negotiation when multiple representations exist.'),
  HttpStatusCode(code: 301, name: 'Moved Permanently', description: 'This and all future requests should be directed to the given URI.', whenToUse: 'Permanent URL redirects. SEO-friendly redirects.'),
  HttpStatusCode(code: 302, name: 'Found', description: 'The resource was found but is temporarily under a different URI.', whenToUse: 'Temporary redirects. Post/Redirect/Get pattern.'),
  HttpStatusCode(code: 303, name: 'See Other', description: 'The response can be found under a different URI and should be retrieved using a GET.', whenToUse: 'After successful form submission.'),
  HttpStatusCode(code: 304, name: 'Not Modified', description: 'The resource has not been modified since the version specified by request headers.', whenToUse: 'Caching: ETag / If-Modified-Since checks.'),
  HttpStatusCode(code: 307, name: 'Temporary Redirect', description: 'The request should be repeated with another URI; however, future requests should still use the original URI.', whenToUse: 'Temporary redirects preserving request method.'),
  HttpStatusCode(code: 308, name: 'Permanent Redirect', description: 'The request and all future requests should be repeated using another URI.', whenToUse: 'Permanent redirects preserving POST method.'),

  // 4xx Client Errors
  HttpStatusCode(code: 400, name: 'Bad Request', description: 'The server cannot or will not process the request due to a client error.', whenToUse: 'Invalid request syntax, invalid parameters, missing required fields.'),
  HttpStatusCode(code: 401, name: 'Unauthorized', description: 'Authentication is required and has failed or has not been provided.', whenToUse: 'Missing or invalid authentication credentials.'),
  HttpStatusCode(code: 402, name: 'Payment Required', description: 'Reserved for future use.', whenToUse: 'Paywall, subscription required.'),
  HttpStatusCode(code: 403, name: 'Forbidden', description: 'The server understood the request but refuses to authorize it.', whenToUse: 'Authenticated but insufficient permissions.'),
  HttpStatusCode(code: 404, name: 'Not Found', description: 'The requested resource could not be found.', whenToUse: 'Resource does not exist at this URL.'),
  HttpStatusCode(code: 405, name: 'Method Not Allowed', description: 'The HTTP method is not supported for the requested resource.', whenToUse: 'Trying POST on a GET-only endpoint.'),
  HttpStatusCode(code: 406, name: 'Not Acceptable', description: 'The requested resource is only capable of generating content not acceptable by the Accept headers.', whenToUse: 'Content negotiation failure.'),
  HttpStatusCode(code: 407, name: 'Proxy Authentication Required', description: 'The client must first authenticate itself with the proxy.', whenToUse: 'Proxy servers requiring login.'),
  HttpStatusCode(code: 408, name: 'Request Timeout', description: 'The server timed out waiting for the request.', whenToUse: 'Client too slow to send request.'),
  HttpStatusCode(code: 409, name: 'Conflict', description: 'The request conflicts with the current state of the resource.', whenToUse: 'Duplicate resource creation, version conflicts.'),
  HttpStatusCode(code: 410, name: 'Gone', description: 'The resource is no longer available and will not be available again.', whenToUse: 'Resource permanently deleted.'),
  HttpStatusCode(code: 411, name: 'Length Required', description: 'The request did not specify the length of its content.', whenToUse: 'Content-Length header missing.'),
  HttpStatusCode(code: 412, name: 'Precondition Failed', description: 'The server does not meet one of the preconditions given in the request headers.', whenToUse: 'If-Match / If-None-Match / If-Unmodified-Since failures.'),
  HttpStatusCode(code: 413, name: 'Payload Too Large', description: 'The request is larger than the server is willing or able to process.', whenToUse: 'File upload size limit exceeded.'),
  HttpStatusCode(code: 414, name: 'URI Too Long', description: 'The URI provided was too long for the server to process.', whenToUse: 'Extremely long query strings.'),
  HttpStatusCode(code: 415, name: 'Unsupported Media Type', description: 'The request entity has a media type which the server or resource does not support.', whenToUse: 'Wrong Content-Type header.'),
  HttpStatusCode(code: 416, name: 'Range Not Satisfiable', description: 'The client has asked for a portion of the file that the server cannot supply.', whenToUse: 'Invalid Range header values.'),
  HttpStatusCode(code: 417, name: 'Expectation Failed', description: 'The server cannot meet the requirements of the Expect request-header field.', whenToUse: 'Expect: 100-continue rejected.'),
  HttpStatusCode(code: 418, name: "I'm a Teapot", description: 'HTCPCP/1.0 — the server refuses to brew coffee because it is a teapot.', whenToUse: 'April Fools RFC 2324. Sometimes used for rate limiting or pranks.'),
  HttpStatusCode(code: 421, name: 'Misdirected Request', description: 'The request was directed at a server that is not able to produce a response.', whenToUse: 'HTTP/2 connection reuse issues.'),
  HttpStatusCode(code: 422, name: 'Unprocessable Entity', description: 'The request was well-formed but was unable to be followed due to semantic errors.', whenToUse: 'Validation errors (wrong data types, business rule violations).'),
  HttpStatusCode(code: 423, name: 'Locked', description: 'The resource that is being accessed is locked.', whenToUse: 'WebDAV locked resources.'),
  HttpStatusCode(code: 424, name: 'Failed Dependency', description: 'The request failed because it depended on another request and that request failed.', whenToUse: 'WebDAV atomic batch failures.'),
  HttpStatusCode(code: 425, name: 'Too Early', description: 'The server is unwilling to risk processing a request that might be replayed.', whenToUse: 'TLS 1.3 early data protection.'),
  HttpStatusCode(code: 426, name: 'Upgrade Required', description: 'The client should switch to a different protocol.', whenToUse: 'Requiring HTTPS or WebSocket upgrade.'),
  HttpStatusCode(code: 428, name: 'Precondition Required', description: 'The origin server requires the request to be conditional.', whenToUse: 'Optimistic concurrency control — require ETag.'),
  HttpStatusCode(code: 429, name: 'Too Many Requests', description: 'The user has sent too many requests in a given amount of time.', whenToUse: 'Rate limiting APIs.'),
  HttpStatusCode(code: 431, name: 'Request Header Fields Too Large', description: 'The server is unwilling to process the request because its header fields are too large.', whenToUse: 'Excessively long cookies or headers.'),
  HttpStatusCode(code: 451, name: 'Unavailable For Legal Reasons', description: 'The server is denying access to the resource as a consequence of a legal demand.', whenToUse: 'GDPR takedowns, court orders, government censorship.'),

  // 5xx Server Errors
  HttpStatusCode(code: 500, name: 'Internal Server Error', description: 'A generic error message for unexpected server conditions.', whenToUse: 'Unhandled exceptions, server-side bugs.'),
  HttpStatusCode(code: 501, name: 'Not Implemented', description: 'The server does not support the functionality required to fulfill the request.', whenToUse: 'HTTP method not implemented on the server.'),
  HttpStatusCode(code: 502, name: 'Bad Gateway', description: 'The server, while acting as a gateway or proxy, received an invalid response from the upstream server.', whenToUse: 'Upstream API is down or returned garbage.'),
  HttpStatusCode(code: 503, name: 'Service Unavailable', description: 'The server is not ready to handle the request.', whenToUse: 'Server maintenance, overloaded, or starting up.'),
  HttpStatusCode(code: 504, name: 'Gateway Timeout', description: 'The server, while acting as a gateway, did not receive a timely response.', whenToUse: 'Upstream service taking too long.'),
  HttpStatusCode(code: 505, name: 'HTTP Version Not Supported', description: 'The server does not support the HTTP protocol version that was used in the request.', whenToUse: 'Sending HTTP/2 to HTTP/1 only server.'),
  HttpStatusCode(code: 506, name: 'Variant Also Negotiates', description: 'Transparent content negotiation for the request results in a circular reference.', whenToUse: 'Misconfigured content negotiation.'),
  HttpStatusCode(code: 507, name: 'Insufficient Storage', description: 'The server is unable to store the representation needed to complete the request.', whenToUse: 'WebDAV disk full.'),
  HttpStatusCode(code: 508, name: 'Loop Detected', description: 'The server detected an infinite loop while processing the request.', whenToUse: 'WebDAV infinite loop in bindings.'),
  HttpStatusCode(code: 510, name: 'Not Extended', description: 'Further extensions to the request are required for the server to fulfill it.', whenToUse: 'HTTP extensions policy not met.'),
  HttpStatusCode(code: 511, name: 'Network Authentication Required', description: 'The client needs to authenticate to gain network access.', whenToUse: 'Captive portal (hotel WiFi login).'),
];
