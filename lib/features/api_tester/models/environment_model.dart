import 'package:uuid/uuid.dart';

class EnvironmentModel {
  final String id;
  final String name;
  final Map<String, String> variables;
  final DateTime createdAt;

  const EnvironmentModel({
    required this.id,
    required this.name,
    this.variables = const {},
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'variables': variables,
        'createdAt': createdAt.toIso8601String(),
      };

  factory EnvironmentModel.fromJson(Map<String, dynamic> json) =>
      EnvironmentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        variables: (json['variables'] as Map<dynamic, dynamic>?)
                ?.cast<String, String>() ??
            {},
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  EnvironmentModel copyWith({
    String? name,
    Map<String, String>? variables,
  }) =>
      EnvironmentModel(
        id: id,
        name: name ?? this.name,
        variables: variables ?? Map.from(this.variables),
        createdAt: createdAt,
      );

  static EnvironmentModel empty() => EnvironmentModel(
        id: const Uuid().v4(),
        name: 'New Environment',
        variables: {},
        createdAt: DateTime.now(),
      );
}
