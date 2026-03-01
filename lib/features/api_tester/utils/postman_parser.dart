import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/request_model.dart';
import '../models/response_model.dart';

class PostmanCollectionParser {
  static const _uuid = Uuid();

  /// Check if the JSON data is a valid Postman v2.1 collection
  static bool isPostmanCollection(Map<String, dynamic> data) {
    return data.containsKey('info') &&
        data.containsKey('item') &&
        data['info'] is Map &&
        (data['info'] as Map).containsKey('schema') &&
        (data['info'] as Map)['schema'].toString().contains('collection.json');
  }

  /// Parse Postman JSON into a pair of (Collection, List of Requests)
  static Map<String, dynamic> parse(Map<String, dynamic> data) {
    final info = data['info'] as Map<String, dynamic>;
    final name = info['name'] ?? 'Imported Collection';
    final collectionId = _uuid.v4();
    final List<RequestModel> requests = [];

    final rawItems = data['item'] as List;
    _extractRequests(rawItems, requests, collectionId);

    final collection = CollectionModel(
      id: collectionId,
      name: name,
      requestIds: requests.map((e) => e.id).toList(),
      createdAt: DateTime.now(),
    );

    return {
      'collection': collection,
      'requests': requests,
    };
  }

  static void _extractRequests(
      List items, List<RequestModel> results, String collectionId) {
    for (var item in items) {
      if (item is! Map) continue;

      // If it has 'request', it's a leaf node (API call)
      if (item.containsKey('request')) {
        final reqData = item['request'];
        final name = item['name'] ?? 'Unnamed Request';

        results.add(_mapToRequestModel(reqData, name, collectionId));
      }
      // If it has 'item', it's a folder, traverse it
      else if (item.containsKey('item')) {
        _extractRequests(item['item'] as List, results, collectionId);
      }
    }
  }

  static RequestModel _mapToRequestModel(
      dynamic req, String name, String collectionId) {
    final method = req is Map ? req['method'] ?? 'GET' : 'GET';
    String urlStr = '';
    Map<String, String> headers = {};
    String body = '';
    String bodyType = 'json';

    if (req is Map) {
      // URL processing
      final urlData = req['url'];
      if (urlData is String) {
        urlStr = urlData;
      } else if (urlData is Map) {
        urlStr = urlData['raw'] ?? '';
      }

      // Headers
      final rawHeaders = req['header'];
      if (rawHeaders is List) {
        for (var h in rawHeaders) {
          if (h is Map && h['disabled'] != true) {
            headers[h['key']] = h['value'] ?? '';
          }
        }
      }

      // Body
      final bodyData = req['body'];
      if (bodyData is Map) {
        final mode = bodyData['mode'];
        if (mode == 'raw') {
          body = bodyData['raw'] ?? '';
          final options = bodyData['options'];
          if (options is Map && options.containsKey('raw')) {
            final language = options['raw']['language'];
            if (language == 'json') bodyType = 'json';
          }
        }
      }

      // Auth (Directly convert to headers)
      final auth = req['auth'];
      if (auth is Map) {
        final type = auth['type'];
        if (type == 'bearer') {
          final bearer = auth['bearer'];
          if (bearer is List && bearer.isNotEmpty) {
            final token = bearer.firstWhere((e) => e['key'] == 'token',
                orElse: () => {'value': ''})['value'];
            headers['Authorization'] = 'Bearer $token';
          }
        } else if (type == 'basic') {
          final basic = auth['basic'];
          if (basic is List && basic.length >= 2) {
            final user = basic.firstWhere((e) => e['key'] == 'username',
                orElse: () => {'value': ''})['value'];
            final pass = basic.firstWhere((e) => e['key'] == 'password',
                orElse: () => {'value': ''})['value'];
            final bytes = utf8.encode('$user:$pass');
            final base64Str = base64.encode(bytes);
            headers['Authorization'] = 'Basic $base64Str';
          }
        }
      }
    } else if (req is String) {
      urlStr = req;
    }

    return RequestModel(
      id: _uuid.v4(),
      name: name,
      method: method,
      url: urlStr,
      headers: headers,
      body: body,
      bodyType: bodyType,
      collectionId: collectionId,
      createdAt: DateTime.now(),
    );
  }
}
