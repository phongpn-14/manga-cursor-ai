import 'package:flutter/material.dart';
import 'package:my_app/services/manga_service.dart';
import '../models/manga.dart';
import 'manga_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _mangaService = MangaService();
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
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search manga...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
          ),
          onSubmitted: _performSearch,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _searchResults == null
          ? const Center(child: Text('Search for manga'))
          : FutureBuilder<List<Manga>>(
              future: _searchResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final mangas = snapshot.data ?? [];
                if (mangas.isEmpty) {
                  return const Center(child: Text('No manga found'));
                }

                return ListView.builder(
                  itemCount: mangas.length,
                  itemBuilder: (context, index) {
                    final manga = mangas[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 40,
                        height: 60,
                        child: manga.coverUrl != null
                            ? Image.network(manga.coverUrl!, fit: BoxFit.cover)
                            : const Icon(Icons.book),
                      ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 