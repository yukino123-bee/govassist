class Announcement {
  final int id;
  final String title;
  final String content;
  final String createdAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt,
    };
  }
}
