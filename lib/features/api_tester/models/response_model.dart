class ResponseModel {
  final int statusCode;
  final String reasonPhrase;
  final Map<String, String> headers;
  final String body;
  final Duration responseTime;
  final int sizeBytes;
  final DateTime receivedAt;
  final String? errorMessage;

  const ResponseModel({
    required this.statusCode,
    required this.reasonPhrase,
    required this.headers,
    required this.body,
    required this.responseTime,
    required this.sizeBytes,
    required this.receivedAt,
    this.errorMessage,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isError => statusCode >= 400;

  static ResponseModel error(String message) => ResponseModel(
        statusCode: 0,
        reasonPhrase: 'Error',
        headers: {},
        body: '',
        responseTime: Duration.zero,
        sizeBytes: 0,
        receivedAt: DateTime.now(),
        errorMessage: message,
      );
}

class CollectionModel {
  final String id;
  final String name;
  final List<String> requestIds;
  final DateTime createdAt;

  const CollectionModel({
    required this.id,
    required this.name,
    required this.requestIds,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'requestIds': requestIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CollectionModel.fromJson(Map<String, dynamic> json) =>
      CollectionModel(
        id: json['id'] as String,
        name: json['name'] as String,
        requestIds: (json['requestIds'] as List<dynamic>).cast<String>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
