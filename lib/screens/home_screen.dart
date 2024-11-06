import 'package:flutter/material.dart';
import '../models/manga.dart';
import '../screens/chapter_list_screen.dart';
import '../services/manga_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _mangaService = MangaService();
  final _searchController = TextEditingController();
  Future<List<Manga>>? _searchResults;

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
      });
      return;
    }

    setState(() {
      _searchResults = _mangaService.searchManga(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MangaDex Reader'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search manga...',
              onSubmitted: _performSearch,
              leading: const Icon(Icons.search),
            ),
          ),
          Expanded(
            child: _searchResults == null
                ? const Center(
                    child: Text('Search for manga'),
                  )
                : FutureBuilder<List<Manga>>(
                    future: _searchResults,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _searchResults = _mangaService
                                        .searchManga(_searchController.text);
                                  });
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final mangas = snapshot.data!;
                      if (mangas.isEmpty) {
                        return const Center(
                          child: Text('No manga found'),
                        );
                      }

                      return ListView.builder(
                        itemCount: mangas.length,
                        itemBuilder: (context, index) {
                          final manga = mangas[index];
                          return ListTile(
                            leading: SizedBox(
                              width: 50,
                              height: 70,
                              child: manga.coverUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        manga.coverUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.book);
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.book),
                            ),
                            title: Text(manga.title),
                            subtitle: Text(manga.authors.join(', ')),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChapterListScreen(manga: manga),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}