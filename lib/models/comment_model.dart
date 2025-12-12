// lib/models/comment_model.dart
class Comment {
  final int id;
  final int userId;
  final String username;
  final String content;
  final String time;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.time,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? json['user']?['id'] ?? 0,
      username: json['user_name'] ?? json['user']?['name'] ?? 'Anonim',
      content: json['content'] ?? '',
      time: json['created_at_human'] ?? 'Baru saja',
    );
  }
}