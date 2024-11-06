class Chapter {
  final String id;
  final String title;
  final String? chapterNumber;
  final List<String> pages;

  Chapter({
    required this.id,
    required this.title,
    this.chapterNumber,
    required this.pages,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    return Chapter(
      id: json['id'],
      title: attributes['title'] ?? 'No Title',
      chapterNumber: attributes['chapter'],
      pages: [], // We'll fetch pages separately
    );
  }
} 