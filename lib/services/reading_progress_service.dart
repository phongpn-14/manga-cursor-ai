import 'package:shared_preferences/shared_preferences.dart';
import '../models/chapter.dart';

class ReadingProgressService {
  static const String _keyPrefix = 'reading_progress_';
  
  Future<void> saveProgress(String mangaId, Chapter chapter, int pageNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyPrefix}$mangaId', chapter.id);
    await prefs.setInt('${_keyPrefix}${chapter.id}_page', pageNumber);
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

  Future<List<String>> getRecentMangaIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys()
        .where((key) => key.startsWith(_keyPrefix))
        .map((key) => key.replaceFirst(_keyPrefix, ''))
        .toList();
  }
} 