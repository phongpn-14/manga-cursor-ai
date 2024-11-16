import '../services/manga_service.dart';

class Manga {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final String? author;
  final DateTime? createdAt;
  final int? chapterCount;

  Manga({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.author,
    this.createdAt,
    this.chapterCount,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'];
    final relationships = json['relationships'] as List;
    
    String? coverFileName;
    String? authorName;

    for (var rel in relationships) {
      if (rel['type'] == 'cover_art') {
        coverFileName = rel['attributes']?['fileName'];
      }
      if (rel['type'] == 'author') {
        authorName = rel['attributes']?['name'];
      }
    }

    return Manga(
      id: json['id'],
      title: attributes['title']['en'] ?? 'No Title',
      description: attributes['description']?['en'],
      coverUrl: coverFileName != null 
          ? 'https://uploads.mangadex.org/covers/${json['id']}/$coverFileName'
          : null,
      author: authorName,
      createdAt: DateTime.tryParse(attributes['createdAt']),
      chapterCount: attributes['chapterCount'],
    );
  }
}