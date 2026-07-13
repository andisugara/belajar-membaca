import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter_model.dart';
import '../widgets/word_bubble.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
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

class _PracticeScreenState extends State<PracticeScreen> {
  late PageController _pageController;
  List<FlatPageItem> _flatPages = [];
  bool _isLoading = true;
  int _currentPageIndex = 0;

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

      setState(() {
        _flatPages = tempFlatPages;
        _pageController = PageController(initialPage: 0);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading chapters data for practice: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        appBar: AppBar(title: const Text('Latihan Mandiri')),
        body: const Center(
          child: Text('Data latihan kosong atau gagal dimuat.'),
        ),
      );
    }

    final currentPageItem = _flatPages[_currentPageIndex];
    final chapter = currentPageItem.chapter;

    return Scaffold(
      backgroundColor: Colors.teal.shade50, // Teal pastel background for Latihan
      body: Stack(
        children: [
          // HEADER (Custom AppBar style matching Latihan theme)
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
                              // Latihan badge (Teal card)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade600,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.school, color: Colors.yellow, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Latihan Chapter ${chapter.chapterNumber} ',
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              
                              // Visual indicator that this is "silent"
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.volume_off, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Coba Baca Sendiri!',
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Subtitle description text
                          Text(
                            chapter.description,
                            style: GoogleFonts.fredoka(
                              color: Colors.teal.shade700.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Side page badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade400,
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
              ),
            ),
          ),

          // MIDDLE CONTENT
          Positioned.fill(
            top: 75,
            bottom: 40,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (idx) {
                setState(() {
                  _currentPageIndex = idx;
                });
              },
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
                                  // Hening / Silent untuk Latihan Mandiri!
                                  // Tapi kita bisa berikan efek visual klik kecil di bubble (sudah ter-handle oleh WordBubble scale animation)
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
                    color: Colors.teal.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.shade900.withOpacity(0.2),
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
