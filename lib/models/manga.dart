import '../services/manga_service.dart';

class Manga {
  final String id;
  final String title;
  final String? coverUrl;
  final List<String> authors;

  Manga({
    required this.id,
    required this.title,
    this.coverUrl,
    required this.authors,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    
    // Handle title properly
    final titleMap = attributes['title'] as Map<String, dynamic>;
    final title = titleMap['en'] ?? titleMap.values.first ?? 'No Title';

    // Handle relationships for authors and cover art
    final relationships = (json['relationships'] as List<dynamic>?) ?? [];
    
    // Get authors
    final authors = relationships
        .where((rel) => rel['type'] == 'author')
        .map((rel) => (rel['attributes']?['name'] ?? 'Unknown Author') as String)
        .toList();

    // If no authors found, add 'Unknown Author'
    if (authors.isEmpty) {
      authors.add('Unknown Author');
    }

    // Get cover art
    String? coverFileName;
    final coverRel = relationships.firstWhere(
      (rel) => rel['type'] == 'cover_art',
      orElse: () => null,
    );
    if (coverRel != null && coverRel['attributes'] != null) {
      coverFileName = coverRel['attributes']['fileName'] as String?;
    }

    return Manga(
      id: json['id'] as String,
      title: title,
      coverUrl: coverFileName != null 
          ? MangaService.getCoverUrl(json['id'] as String, coverFileName)
          : null,
      authors: authors,
    );
  }
}