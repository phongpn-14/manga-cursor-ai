import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../services/manga_service.dart';
import 'reader_screen.dart';

class ChapterListScreen extends StatefulWidget {
  final Manga manga;

  const ChapterListScreen({super.key, required this.manga});

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  final _mangaService = MangaService();
  late Future<List<Chapter>> _chapters;

  @override
  void initState() {
    super.initState();
    _chapters = _mangaService.getChapters(widget.manga.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manga.title),
      ),
      body: FutureBuilder<List<Chapter>>(
        future: _chapters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final chapters = snapshot.data!;
          if (chapters.isEmpty) {
            return const Center(
              child: Text('No chapters available'),
            );
          }

          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return ListTile(
                title: Text('Chapter ${chapter.chapterNumber ?? 'N/A'}'),
                subtitle: Text(chapter.title),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReaderScreen(chapter: chapter),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 