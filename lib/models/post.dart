class Post {
  final int id;
  final String title;
  final String body;
  final int userId;
  final DateTime? date;

  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.date,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      userId: json['userId'],
      date: DateTime.now().subtract(Duration(days: json['id'])),
    );
  }
}
