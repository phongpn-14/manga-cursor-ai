import 'package:flutter/material.dart';
import 'package:my_app/services/reading_progress_service.dart';
import '../models/chapter.dart';
import '../services/manga_service.dart';

class ReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final int initialPage;
  final String mangaId;
  
  const ReaderScreen({super.key, required this.chapter, this.initialPage = 0, required this.mangaId});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _mangaService = MangaService();
  final _progressService = ReadingProgressService();

  late Future<List<String>> _pages;
  late PageController _pageController;
  int _currentPage = 1;
  final Map<int, Widget> _cachedImages = {};
  final int _preloadDistance = 2; // Number of pages to preload ahead

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage + 1;
    _pageController = PageController(initialPage: widget.initialPage);
    _pages = _mangaService.getChapterPages(widget.chapter.id);
    _pages.then((pages) {
      // Start preloading first few pages
      _preloadImages(0, pages);
    });
  }

   void _saveProgress() {
    _progressService.saveProgress(
      widget.chapter.id,  // Add mangaId to your Chapter model if not exists
      widget.chapter,
      _currentPage
    );
  }

  void _nextPage() {
    if (_pageController.page! < _pageController.position.maxScrollExtent) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _preloadImages(int currentIndex, List<String> pages) {
    final int end = (currentIndex + _preloadDistance).clamp(0, pages.length - 1);
    for (var i = currentIndex; i <= end; i++) {
      if (!_cachedImages.containsKey(i)) {
        // Force preload the image into cache
        precacheImage(
          NetworkImage(pages[i]),
          context,
        );
        
        // Create and cache the widget
        _cachedImages[i] = Image.network(
          pages[i],
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error_outline),
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${widget.chapter.chapterNumber ?? 'N/A'}'),
      ),
      body: FutureBuilder<List<String>>(
        future: _pages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final pages = snapshot.data!;
          return Stack(
            children: [
              // Modified PageView
              PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index + 1;
                    // Add preloading here to ensure it happens on every page change
                    _preloadImages(index, pages);
                    _saveProgress();  // Save progress when page changes

                  });
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.0,
                    child: _cachedImages[index] ?? Image.network(
                      pages[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          _cachedImages[index] = child;
                          // Preload starting from current index
                          _preloadImages(index, pages);
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error_outline),
                        );
                      },
                    ),
                  );
                },
              ),

              // Modify navigation overlay for vertical scrolling
              Positioned.fill(
                child: Column(
                  children: [
                    // Previous page touch area
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: _previousPage,
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    // Next page touch area
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: _nextPage,
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation Buttons
              Positioned(
                left: 0,
                right: 0,
                bottom: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous Button
                    if (_currentPage > 1)
                      ElevatedButton(
                        onPressed: _previousPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back),
                            SizedBox(width: 8),
                            Text('Previous'),
                          ],
                        ),
                      ),
                    const SizedBox(width: 16),
                    // Next Button
                    if (_currentPage < pages.length)
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Next'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Page Counter
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Page $_currentPage/${pages.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _cachedImages.clear();
    _pageController.dispose();
    super.dispose();
  }
}