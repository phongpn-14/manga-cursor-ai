import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga.dart';
import '../models/chapter.dart';

class MangaService {
  static const baseUrl = 'https://api.mangadex.org';
  static const coverBaseUrl = 'https://uploads.mangadex.org/covers';

  Future<List<Manga>> searchManga(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/manga?title=$query&limit=20&includes[]=author&includes[]=cover_art'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> mangaList = data['data'] ?? [];
        
        return mangaList.map((manga) => Manga.fromJson(manga)).toList();
      } else {
        throw Exception('Failed to search manga: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching manga: $e');
      throw Exception('Failed to search manga: $e');
    }
  }

  Future<List<Chapter>> getChapters(String mangaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/manga/$mangaId/feed?translatedLanguage[]=en&order[chapter]=asc'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List)
            .map((chapter) => Chapter.fromJson(chapter))
            .toList();
      } else {
        throw Exception('Failed to load chapters');
      }
    } catch (e) {
      throw Exception('Failed to load chapters: $e');
    }
  }

  Future<List<String>> getChapterPages(String chapterId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/at-home/server/$chapterId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final baseUrl = data['baseUrl'];
        final hash = data['chapter']['hash'];
        final pages = (data['chapter']['data'] as List).cast<String>();

        return pages
            .map((page) => '$baseUrl/data/$hash/$page')
            .toList();
      } else {
        throw Exception('Failed to load chapter pages');
      }
    } catch (e) {
      throw Exception('Failed to load chapter pages: $e');
    }
  }

  static String? getCoverUrl(String mangaId, String? fileName) {
    if (fileName == null) return null;
    return '$coverBaseUrl/$mangaId/$fileName';
  }
}