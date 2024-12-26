class Post {
  final int id;
  final String body;
  final String datePosted;
  final String author;

  Post(
      {required this.id,
      required this.body,
      required this.datePosted,
      required this.author});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      body: json['body'],
      datePosted: json['date_posted'],
      author: json['author'],
    );
  }
}
