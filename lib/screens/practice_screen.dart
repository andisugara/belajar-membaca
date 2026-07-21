import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter_model.dart';
import '../widgets/word_bubble.dart';

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

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
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
        body: Center(
          child: Text(
            'Data latihan kosong atau gagal dimuat.',
            style: GoogleFonts.fredoka(fontSize: 20),
          ),
        ),
      );
    }

    final currentPageItem = _flatPages[_currentPageIndex];
    final chapter = currentPageItem.chapter;
    final page = currentPageItem.page;

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background to match screenshot
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;
          
          final double titleFontSize = isLandscape ? 54.0 : 36.0;
          final double gridFontSize = isLandscape ? 36.0 : 26.0;
          final double horizontalPadding = isLandscape ? 80.0 : 24.0;

          return Stack(
            children: [
              // MAIN LAYOUT
              Column(
                children: [
                  // HEADER BAR (Teal Theme)
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
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
                                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Latihan badge (Teal card)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade600,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.school, color: Colors.yellow, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Latihan Chapter ${chapter.chapterNumber}',
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // Indicator that this is "silent/self-read"
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade700,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
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
                          const SizedBox(height: 6),
                          
                          // Subtitle and progress indicator Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Subtitle
                              Expanded(
                                child: Text(
                                  chapter.description,
                                  style: GoogleFonts.fredoka(
                                    color: Colors.teal.shade700.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              
                              // Page Indicator Box
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade400,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.assignment_rounded, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${_currentPageIndex + 1}/${_flatPages.length}',
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
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
                  
                  // GRID CONTENT
                  Expanded(
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
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(pageItem.page.rows.length, (r) {
                                  final row = pageItem.page.rows[r];
                                  final isFirstRow = r == 0;
                                  
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: isFirstRow ? 12.0 : 6.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(row.length, (c) {
                                        final word = row[c];
                                        return WordBubble(
                                          item: word,
                                          fontSize: isFirstRow ? titleFontSize : gridFontSize,
                                          onTap: () {
                                            // Silent mode: clicking does not trigger audio
                                          },
                                        );
                                      }),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // PORTRAIT NAVIGATION (At the bottom, so it doesn't overlap text)
                  if (!isLandscape)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPrevButton(),
                          _buildNextButton(),
                        ],
                      ),
                    )
                  else
                    const SizedBox(height: 20), // Bottom padding in landscape
                ],
              ),

              // LANDSCAPE NAVIGATION (Floating in the bottom corners)
              if (isLandscape) ...[
                if (_currentPageIndex > 0)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: _buildPrevButton(),
                  ),
                if (_currentPageIndex < _flatPages.length - 1)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: _buildNextButton(),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPrevButton() {
    if (_currentPageIndex == 0) return const SizedBox(width: 52);
    return GestureDetector(
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
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildNextButton() {
    if (_currentPageIndex == _flatPages.length - 1) return const SizedBox(width: 52);
    return GestureDetector(
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
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 24),
      ),
    );
  }
}
