import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter_model.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../widgets/word_bubble.dart';

class ReadingScreen extends StatefulWidget {
  final String? initialChapterId;
  final int? initialPageIndex;

  const ReadingScreen({
    super.key,
    this.initialChapterId,
    this.initialPageIndex,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class FlatPageItem {
  final Chapter chapter;
  final ChapterPage page;
  final int pageIndexInChapter;

  FlatPageItem({
    required this.chapter,
    required this.page,
    required this.pageIndexInChapter,
  });
}

class _ReadingScreenState extends State<ReadingScreen> {
  final AudioService _audioService = AudioService();
  late PageController _pageController;
  
  List<FlatPageItem> _flatPages = [];
  bool _isLoading = true;
  int _currentPageIndex = 0;
  bool _isMarkedAsLastRead = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/chapters.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final List<Chapter> chapters = jsonList.map((item) => Chapter.fromJson(item as Map<String, dynamic>)).toList();
      
      final List<FlatPageItem> tempFlatPages = [];
      for (var chapter in chapters) {
        for (int i = 0; i < chapter.pages.length; i++) {
          tempFlatPages.add(
            FlatPageItem(
              chapter: chapter,
              page: chapter.pages[i],
              pageIndexInChapter: i,
            ),
          );
        }
      }

      int startPageIndex = 0;
      if (widget.initialChapterId != null && widget.initialPageIndex != null) {
        final idx = tempFlatPages.indexWhere((item) =>
            item.chapter.id == widget.initialChapterId &&
            item.pageIndexInChapter == widget.initialPageIndex);
        if (idx != -1) {
          startPageIndex = idx;
        }
      }

      // Check if current loaded page is saved as progress
      final savedProgress = await ProgressService.getProgress();
      bool marked = false;
      if (savedProgress != null && tempFlatPages.isNotEmpty) {
        final currentFlatPage = tempFlatPages[startPageIndex];
        if (currentFlatPage.chapter.id == savedProgress['chapterId'] &&
            currentFlatPage.pageIndexInChapter == savedProgress['pageIndex']) {
          marked = true;
        }
      }

      setState(() {
        _flatPages = tempFlatPages;
        _currentPageIndex = startPageIndex;
        _isMarkedAsLastRead = marked;
        _pageController = PageController(initialPage: startPageIndex);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading chapters data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioService.stop();
    super.dispose();
  }

  Future<void> _onPageChanged(int index) async {
    // Stop any running page audio when switching pages
    await _audioService.stop();

    final savedProgress = await ProgressService.getProgress();
    final currentFlatPage = _flatPages[index];
    bool marked = false;
    if (savedProgress != null) {
      if (currentFlatPage.chapter.id == savedProgress['chapterId'] &&
          currentFlatPage.pageIndexInChapter == savedProgress['pageIndex']) {
        marked = true;
      }
    }

    setState(() {
      _currentPageIndex = index;
      _isMarkedAsLastRead = marked;
    });
  }

  Future<void> _toggleLastReadMark(bool? checked) async {
    if (checked == null) return;
    
    final currentFlatPage = _flatPages[_currentPageIndex];
    if (checked) {
      await ProgressService.saveProgress(
        currentFlatPage.chapter.id,
        currentFlatPage.pageIndexInChapter,
      );
      setState(() {
        _isMarkedAsLastRead = true;
      });
    } else {
      await ProgressService.clearProgress();
      setState(() {
        _isMarkedAsLastRead = false;
      });
    }
  }

  Future<void> _playCurrentPageAudio() async {
    final currentFlatPage = _flatPages[_currentPageIndex];
    await _audioService.playAsset(currentFlatPage.page.pageAudio);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_flatPages.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Belajar Membaca')),
        body: const Center(
          child: Text('Data belajar kosong atau gagal dimuat.'),
        ),
      );
    }

    final currentPageItem = _flatPages[_currentPageIndex];
    final chapter = currentPageItem.chapter;
    final page = currentPageItem.page;

    return Scaffold(
      backgroundColor: Colors.grey.shade50, // clean background matching screenshot
      body: Stack(
        children: [
          // HEADER (Custom AppBar style to match the screenshot)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button (red circle)
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.shade900.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Chapter badge & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Chapter badge (orange card)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade600,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.circle, color: Colors.yellow, size: 10),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Chapter  ',
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${chapter.chapterNumber}',
                                        style: GoogleFonts.fredoka(
                                          color: Colors.orange.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              
                              // Suara Button (Green)
                              GestureDetector(
                                onTap: _playCurrentPageAudio,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade500,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.shade700,
                                        offset: const Offset(0, 3),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.volume_up, color: Colors.white, size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Suara',
                                        style: GoogleFonts.fredoka(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Subtitle description text
                          Text(
                            chapter.description,
                            style: GoogleFonts.fredoka(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Side items: Last Read Checkbox & Page Badge
                    Row(
                      children: [
                        // Checkbox last read
                        Checkbox(
                          value: _isMarkedAsLastRead,
                          activeColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: _toggleLastReadMark,
                        ),
                        Text(
                          'Tandai terakhir dibaca',
                          style: GoogleFonts.fredoka(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Page Badge (Blue Box)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.assignment_rounded, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '${_currentPageIndex + 1}/${_flatPages.length}',
                                style: GoogleFonts.fredoka(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // MIDDLE CONTENT (Word Syllables grid view)
          Positioned.fill(
            top: 75,
            bottom: 40,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _flatPages.length,
              itemBuilder: (context, idx) {
                final pageItem = _flatPages[idx];
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pageItem.page.rows.map((row) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: row.map((word) {
                              return WordBubble(
                                item: word,
                                onTap: () {
                                  _audioService.playAsset(word.audio);
                                },
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),

          // PREVIOUS PAGE BUTTON (Bottom Left)
          if (_currentPageIndex > 0)
            Positioned(
              bottom: 20,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),

          // NEXT PAGE BUTTON (Bottom Right)
          if (_currentPageIndex < _flatPages.length - 1)
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade900.withOpacity(0.2),
                        offset: const Offset(0, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
