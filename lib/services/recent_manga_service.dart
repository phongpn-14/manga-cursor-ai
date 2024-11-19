import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' if (dart.library.html) 'dart:html' as html;
import 'dart:convert';
import '../models/manga.dart';

class RecentMangaService {
  static const String _recentMangaKey = 'recent_manga_';
  static const int _maxRecentManga = 10;  // Maximum number of recent manga to store

  Future<void> addToRecent(Manga manga) async {
    try {
      final recentManga = await getRecentManga();
      
      // Remove if manga already exists in recents
      recentManga.removeWhere((m) => m.id == manga.id);
      
      // Add to beginning of list
      recentManga.insert(0, manga);
      
      // Keep only the most recent items
      if (recentManga.length > _maxRecentManga) {
        recentManga.removeLast();
      }

      // Save updated list
      await _saveRecentList(recentManga);
    } catch (e) {
      print('Error adding manga to recents: $e');
    }
  }

  Future<List<Manga>> getRecentManga() async {
    try {
      final String? jsonString = await _getStoredData();
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Manga.fromJson(json)).toList();
    } catch (e) {
      print('Error getting recent manga: $e');
      return [];
    }
  }

  Future<void> _saveRecentList(List<Manga> mangaList) async {
    final jsonString = json.encode(
      mangaList.map((manga) => {
        'id': manga.id,
        'title': manga.title,
        'coverUrl': manga.coverUrl,
        'author': manga.author,
        'description': manga.description,
      }).toList()
    );

    if (kIsWeb) {
      html.window.localStorage[_recentMangaKey] = jsonString;
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_recentMangaKey, jsonString);
    }
  }

  Future<String?> _getStoredData() async {
    if (kIsWeb) {
      return html.window.localStorage[_recentMangaKey];
    } else {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_recentMangaKey);
    }
  }

  Future<void> clearRecent() async {
    if (kIsWeb) {
      html.window.localStorage.remove(_recentMangaKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentMangaKey);
    }
  }
} 