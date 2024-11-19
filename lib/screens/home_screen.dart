import 'package:flutter/material.dart';
import 'package:my_app/services/manga_service.dart';
import '../models/manga.dart';
import '../services/reading_progress_service.dart';
import 'manga_detail_screen.dart';
import 'search_screen.dart';
import '../services/recent_manga_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _progressService = ReadingProgressService();
  late Future<List<Manga>> _recentManga;

  @override
  void initState() {
    super.initState();
    _loadRecentManga();
  }

  Future<void> _loadRecentManga() async {
    setState(() {
      _recentManga = _progressService.getRecentManga();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MangaDex Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Manga>>(
        future: _recentManga,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final mangas = snapshot.data ?? [];
          if (mangas.isEmpty) {
            return const Center(child: Text('No recent manga'));
          }

          return ListView.builder(
            itemCount: mangas.length,
            itemBuilder: (context, index) {
              final manga = mangas[index];
              return ListTile(
                leading: manga.coverUrl != null
                    ? Image.network(
                        manga.coverUrl!,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      )
                    : const Icon(Icons.book),
                title: Text(manga.title),
                subtitle: Text(manga.author ?? 'Unknown Author'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MangaDetailScreen(manga: manga),
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