import 'package:flutter/material.dart';
import 'package:my_app/models/chapter.dart';
import 'package:my_app/models/manga.dart';
import 'package:my_app/screens/reader_screen.dart';
import 'package:my_app/services/manga_service.dart';
import 'package:my_app/services/reading_progress_service.dart';

class MangaDetailScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  final _progressService = ReadingProgressService();
  late Future<List<Chapter>> _chapters;

  @override
  void initState() {
    super.initState();
    _chapters = MangaService().getChapters(widget.manga.id);
  }

  Future<void> _resumeReading(List<Chapter> chapters) async {
    final saveProgress = await _progressService.getProgress(widget.manga.id);
    final lastChapterId = saveProgress?['chapterId'];
    final lastPageNumber = saveProgress?['pageNumber'];
    if (lastChapterId != null && lastPageNumber != null) {
      final chapter = chapters.firstWhere(
        (c) => c.id == lastChapterId,
        orElse: () => chapters.first,
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReaderScreen(
              chapter: chapter,
              initialPage: lastPageNumber,
              mangaId: widget.manga.id,
              manga: widget.manga,
            ),
          ),
        );
      }
    }
  }

  void _openReader(Chapter chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderScreen(
          chapter: chapter,
          mangaId: widget.manga.id,
          manga: widget.manga,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.manga.title),
      ),
      body: Column(
        children: [
          // Manga Info Card
          Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.manga.coverUrl ?? '',
                      width: 100,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Manga Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.manga.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Author: ${widget.manga.author ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Created: ${widget.manga.createdAt ?? 'Unknown'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.manga.chapterCount ?? 0} chapters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Chapter List with Continue Reading Button
          Expanded(
            child: FutureBuilder<List<Chapter>>(
              future: _chapters,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final chapters = snapshot.data ?? [];
                return Column(
                  children: [
                    // Continue Reading Button
                    FutureBuilder<Map<String, dynamic>?>(
                      future: _progressService.getProgress(widget.manga.id),
                      builder: (context, progressSnapshot) {
                        if (progressSnapshot.hasData && progressSnapshot.data != null) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () => _resumeReading(chapters),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(40),
                              ),
                              child: const Text('Continue Reading'),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // Chapter List
                    Expanded(
                      child: ListView.builder(
                        itemCount: chapters.length,
                        itemBuilder: (context, index) {
                          final chapter = chapters[index];
                          return ListTile(
                            title: Text('Chapter ${chapter.chapterNumber}'),
                            subtitle: Text(chapter.title),
                            onTap: () {
                              _progressService.saveProgress(widget.manga.id, chapter, 1, widget.manga);
                              _openReader(chapter);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}