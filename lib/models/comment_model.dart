class Comment {
  final int id;
  final int newsId;
  final int userId;
  final String username;
  final String content;
  final String time;

  Comment({
    required this.id,
    required this.newsId,
    required this.userId,
    required this.username,
    required this.content,
    required this.time,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      newsId: json['news_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      // Mengambil nama user dari object nested 'user' di API
      username: json['user']?['name'] ?? 'Anonim', 
      // MENGAMBIL DATA DARI KOLOM 'body' SESUAI DATABASE
      content: json['body'] ?? '', 
      time: json['created_at'] ?? '',
    );
  }
}