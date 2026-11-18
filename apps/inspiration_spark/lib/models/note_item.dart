enum NoteKind { inspiration, note }

class NoteItem {
  NoteItem({
    required this.id,
    required this.kind,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final NoteKind kind;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NoteItem copyWith({
    String? content,
    DateTime? updatedAt,
  }) {
    return NoteItem(
      id: id,
      kind: kind,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String,
      kind: NoteKind.values.firstWhere((e) => e.name == json['kind']),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );
  }
}
