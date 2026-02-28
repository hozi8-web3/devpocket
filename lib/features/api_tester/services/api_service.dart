import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/request_model.dart';
import '../models/response_model.dart';

class ApiService {
  static Future<ResponseModel> sendRequest(
    RequestModel request, {
    int timeoutSeconds = 30,
  }) async {
    final dio = Dio(BaseOptions(
      connectTimeout: Duration(seconds: timeoutSeconds),
      receiveTimeout: Duration(seconds: timeoutSeconds),
      sendTimeout: Duration(seconds: timeoutSeconds),
      validateStatus: (_) => true, // accept all status codes
      responseType: ResponseType.plain,
    ));

    // Build URL with params
    String url = request.url.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    if (request.params.isNotEmpty) {
      final query = request.params.entries
          .where((e) => e.key.isNotEmpty)
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url += url.contains('?') ? '&$query' : '?$query';
    }

    // Build headers
    final headers = <String, String>{};
    headers.addAll(request.headers);

    // Auth
    if (request.bearerToken?.isNotEmpty == true) {
      headers['Authorization'] = 'Bearer ${request.bearerToken}';
    } else if (request.basicAuthUser?.isNotEmpty == true) {
      final creds = base64Encode(
          utf8.encode('${request.basicAuthUser}:${request.basicAuthPassword}'));
      headers['Authorization'] = 'Basic $creds';
    } else if (request.apiKey?.isNotEmpty == true) {
      final hdr = request.apiKeyHeader?.isNotEmpty == true
          ? request.apiKeyHeader!
          : 'X-API-Key';
      headers[hdr] = request.apiKey!;
    }

    // Content-Type for body requests
    dynamic data;
    if (['POST', 'PUT', 'PATCH', 'DELETE'].contains(request.method) &&
        request.body.isNotEmpty) {
      if (request.bodyType == 'json') {
        data = request.body;
        headers['Content-Type'] = 'application/json';
      } else {
        data = request.body;
      }
    }

    try {
      final stopwatch = Stopwatch()..start();

      final response = await dio.request(
        url,
        data: data,
        options: Options(
          method: request.method,
          headers: headers,
        ),
      );

      stopwatch.stop();

      final bodyStr = response.data?.toString() ?? '';
      final sizeBytes = utf8.encode(bodyStr).length;

      final responseHeaders = <String, String>{};
      response.headers.forEach((name, values) {
        responseHeaders[name] = values.join(', ');
      });

      return ResponseModel(
        statusCode: response.statusCode ?? 0,
        reasonPhrase: _reasonPhrase(response.statusCode ?? 0),
        headers: responseHeaders,
        body: bodyStr,
        responseTime: stopwatch.elapsed,
        sizeBytes: sizeBytes,
        receivedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return ResponseModel.error(
            'Request timed out after ${timeoutSeconds}s');
      }
      return ResponseModel.error(e.message ?? 'Network error occurred');
    } catch (e) {
      return ResponseModel.error(e.toString());
    }
  }

  static String _reasonPhrase(int code) {
    const phrases = {
      200: 'OK', 201: 'Created', 204: 'No Content', 400: 'Bad Request',
      401: 'Unauthorized', 403: 'Forbidden', 404: 'Not Found',
      405: 'Method Not Allowed', 408: 'Request Timeout', 409: 'Conflict',
      422: 'Unprocessable Entity', 429: 'Too Many Requests',
      500: 'Internal Server Error', 502: 'Bad Gateway',
      503: 'Service Unavailable', 504: 'Gateway Timeout',
    };
    return phrases[code] ?? 'Unknown';
  }
}
