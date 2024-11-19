import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chapter.dart';
import '../models/manga.dart';

class ReadingProgressService {
  static const String _keyPrefix = 'reading_progress_';
  static const String _mangaDataPrefix = 'manga_data_';
  static const String _recentListKey = 'recent_manga_list';  // Add this

  Future<void> saveProgress(String mangaId, Chapter chapter, int pageNumber, Manga manga) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save reading progress
    await prefs.setString('${_keyPrefix}$mangaId', chapter.id);
    await prefs.setInt('${_keyPrefix}${chapter.id}_page', pageNumber);
    
    // Save manga data
    final mangaData = {
      'id': manga.id,
      'title': manga.title,
      'coverUrl': manga.coverUrl,
      'author': manga.author,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString('${_mangaDataPrefix}$mangaId', json.encode(mangaData));

    // Update recent list
    List<String> recentList = [];
    final recentString = prefs.getString(_recentListKey);
    if (recentString != null) {
      recentList = List<String>.from(json.decode(recentString));
    }
    
    // Remove if exists and add to front
    recentList.remove(mangaId);
    recentList.insert(0, mangaId);
    
    // Keep only last 20 items
    if (recentList.length > 20) {
      recentList = recentList.sublist(0, 20);
    }
    
    // Save updated list
    await prefs.setString(_recentListKey, json.encode(recentList));
  }

  Future<List<Manga>> getRecentManga() async {
    final prefs = await SharedPreferences.getInstance();
    final mangaList = <Manga>[];
    
    // Get recent list
    final recentString = prefs.getString(_recentListKey);
    if (recentString == null) return [];
    
    final recentIds = List<String>.from(json.decode(recentString));
    
    // Load manga data for each ID
    for (final id in recentIds) {
      final mangaString = prefs.getString('${_mangaDataPrefix}$id');
      if (mangaString != null) {
        try {
          final data = json.decode(mangaString) as Map<String, dynamic>;
          mangaList.add(Manga(
            id: data['id'],
            title: data['title'],
            coverUrl: data['coverUrl'],
            author: data['author'],
          ));
        } catch (e) {
          print('Error parsing manga data for $id: $e');
        }
      }
    }
    
    return mangaList;
  }

  Future<Map<String, dynamic>?> getProgress(String mangaId) async {
    final prefs = await SharedPreferences.getInstance();
    final chapterId = prefs.getString('${_keyPrefix}$mangaId');
    if (chapterId == null) return null;
    
    final pageNumber = prefs.getInt('${_keyPrefix}${chapterId}_page') ?? 1;
    return {
      'chapterId': chapterId,
      'pageNumber': pageNumber,
    };
  }

  Future<void> clearProgress(String mangaId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_keyPrefix}$mangaId');
    await prefs.remove('${_mangaDataPrefix}$mangaId');
    
    // Remove from recent list
    final recentString = prefs.getString(_recentListKey);
    if (recentString != null) {
      final recentList = List<String>.from(json.decode(recentString));
      recentList.remove(mangaId);
      await prefs.setString(_recentListKey, json.encode(recentList));
    }
  }
}