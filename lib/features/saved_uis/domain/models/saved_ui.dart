import 'dart:convert';

class SavedUi {
  final String id; // unique id (e.g., timestamp or uuid) 
  final String name;
  final Map<String, dynamic> json;
  final DateTime createdAt;

  const SavedUi({
    required this.id,
    required this.name,
    required this.json,
    required this.createdAt,
  });

  SavedUi copyWith({String? name}) => SavedUi(
        id: id,
        name: name ?? this.name,
        json: json,
        createdAt: createdAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'json': json,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedUi.fromMap(Map<String, dynamic> map) => SavedUi(
        id: map['id'] as String,
        name: map['name'] as String,
        json: (map['json'] as Map).cast<String, dynamic>(),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );

  String toJsonString() => jsonEncode(toMap());
  factory SavedUi.fromJsonString(String s) => SavedUi.fromMap(
        jsonDecode(s) as Map<String, dynamic>,
      );
}
