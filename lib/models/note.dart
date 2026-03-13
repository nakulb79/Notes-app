import 'dart:ui';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final List<String> tags;
  final Map<String, dynamic>? metadata;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.tags = const [],
    this.metadata,
  });

  Color? getColor() {
    final hex = metadata?['color'];
    if (hex is! String || hex.isEmpty) {
      return null;
    }
    final value = hex.replaceFirst('#', '');
    if (value.length != 6) {
      return null;
    }
    final parsed = int.tryParse('FF$value', radix: 16);
    if (parsed == null) {
      return null;
    }
    return Color(parsed);
  }

  Note withColor(String hex) {
    final nextMetadata = <String, dynamic>{...?metadata};
    nextMetadata['color'] = hex;
    return copyWith(metadata: nextMetadata);
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'tags': tags,
      'metadata': metadata,
    };
  }

  factory Note.fromJson(Map<dynamic, dynamic> json) {
    final rawTags = json['tags'];
    final rawMetadata = json['metadata'];

    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPinned: json['isPinned'] as bool? ?? false,
      tags: rawTags == null
          ? const []
          : List<String>.from((rawTags as List).map((e) => e.toString())),
      metadata: rawMetadata == null
          ? null
          : Map<String, dynamic>.from(rawMetadata as Map),
    );
  }
}
