import 'package:hive_flutter/hive_flutter.dart';

class RequestModel {
  String id;
  String method;
  String url;
  Map<String, String> headers;
  Map<String, String> params;
  String body;
  String bodyType; // 'json', 'form', 'raw'
  String? bearerToken;
  String? basicAuthUser;
  String? basicAuthPassword;
  String? apiKey;
  String? apiKeyHeader;
  DateTime createdAt;
  String? collectionId;
  String? name;

  RequestModel({
    required this.id,
    this.method = 'GET',
    this.url = '',
    Map<String, String>? headers,
    Map<String, String>? params,
    this.body = '',
    this.bodyType = 'json',
    this.bearerToken,
    this.basicAuthUser,
    this.basicAuthPassword,
    this.apiKey,
    this.apiKeyHeader,
    DateTime? createdAt,
    this.collectionId,
    this.name,
  })  : headers = headers ?? {},
        params = params ?? {},
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'url': url,
        'headers': headers,
        'params': params,
        'body': body,
        'bodyType': bodyType,
        'bearerToken': bearerToken,
        'basicAuthUser': basicAuthUser,
        'basicAuthPassword': basicAuthPassword,
        'apiKey': apiKey,
        'apiKeyHeader': apiKeyHeader,
        'createdAt': createdAt.toIso8601String(),
        'collectionId': collectionId,
        'name': name,
      };

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
        id: json['id'] as String,
        method: json['method'] as String? ?? 'GET',
        url: json['url'] as String? ?? '',
        headers: (json['headers'] as Map<dynamic, dynamic>?)
                ?.cast<String, String>() ??
            {},
        params: (json['params'] as Map<dynamic, dynamic>?)
                ?.cast<String, String>() ??
            {},
        body: json['body'] as String? ?? '',
        bodyType: json['bodyType'] as String? ?? 'json',
        bearerToken: json['bearerToken'] as String?,
        basicAuthUser: json['basicAuthUser'] as String?,
        basicAuthPassword: json['basicAuthPassword'] as String?,
        apiKey: json['apiKey'] as String?,
        apiKeyHeader: json['apiKeyHeader'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        collectionId: json['collectionId'] as String?,
        name: json['name'] as String?,
      );

  RequestModel copyWith({
    String? method,
    String? url,
    Map<String, String>? headers,
    Map<String, String>? params,
    String? body,
    String? bodyType,
    String? bearerToken,
    String? basicAuthUser,
    String? basicAuthPassword,
    String? apiKey,
    String? apiKeyHeader,
    String? collectionId,
    String? name,
  }) =>
      RequestModel(
        id: id,
        method: method ?? this.method,
        url: url ?? this.url,
        headers: headers ?? Map.from(this.headers),
        params: params ?? Map.from(this.params),
        body: body ?? this.body,
        bodyType: bodyType ?? this.bodyType,
        bearerToken: bearerToken ?? this.bearerToken,
        basicAuthUser: basicAuthUser ?? this.basicAuthUser,
        basicAuthPassword: basicAuthPassword ?? this.basicAuthPassword,
        apiKey: apiKey ?? this.apiKey,
        apiKeyHeader: apiKeyHeader ?? this.apiKeyHeader,
        createdAt: createdAt,
        collectionId: collectionId ?? this.collectionId,
        name: name ?? this.name,
      );
}
