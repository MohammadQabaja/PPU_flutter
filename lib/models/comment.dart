class Comment {
  final int id;
  String body;
  final String datePosted;
  final String author;
  final int likesCount;

  Comment({
    required this.id,
    required this.body,
    required this.datePosted,
    required this.author,
    required this.likesCount,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,  // إذا كانت القيمة null، استخدم 0
      body: json['body'] ?? "",  // إذا كانت القيمة null، استخدم نص فارغ
      datePosted: json['date_posted'] ?? "",  // إذا كانت القيمة null، استخدم نص فارغ
      author: json['author'] ?? "",  // إذا كانت القيمة null، استخدم نص فارغ
      likesCount: json['likes_count'] ?? 0,  // إذا كانت القيمة null، استخدم 0
    );
  }
}
