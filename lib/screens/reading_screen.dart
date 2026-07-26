import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chapter_model.dart';
import '../services/audio_service.dart';
import '../services/progress_service.dart';
import '../widgets/word_bubble.dart';
import 'music_guide_screen.dart';

class ReadingScreen extends StatefulWidget {
  final ReadingType type;
  final String? initialChapterId;
  final int? initialPageIndex;

  const ReadingScreen({
    super.key,
    this.type = ReadingType.konsonan,
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

  // Audio Control States
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final jsonAsset = widget.type == ReadingType.sengau
          ? 'assets/data/chapters_sengau.json'
          : 'assets/data/chapters_konsonan.json';
      final jsonString = await rootBundle.loadString(jsonAsset);
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

      setState(() {
        _flatPages = tempFlatPages;
        _currentPageIndex = startPageIndex;
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
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _onPageChanged(int index) async {
    final currentFlatPage = _flatPages[index];
    await ProgressService.saveProgress(
      currentFlatPage.chapter.id,
      currentFlatPage.pageIndexInChapter,
    );

    setState(() {
      _currentPageIndex = index;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _audioService.isMuted = _isMuted;
    });
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
            'Data belajar kosong atau gagal dimuat.',
            style: GoogleFonts.fredoka(fontSize: 20),
          ),
        ),
      );
    }

    final currentPageItem = _flatPages[_currentPageIndex];
    final chapter = currentPageItem.chapter;

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background as in the screenshot
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
                  // HEADER BAR
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 4.0, bottom: 2.0),
                      child: Row(
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
                              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                          // Chapter title badge (orange card)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.circle, color: Colors.yellow, size: 10),
                                const SizedBox(width: 6),
                                Text(
                                  chapter.title.isNotEmpty ? chapter.title : 'Chapter ${chapter.chapterNumber}',
                                  style: GoogleFonts.fredoka(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Toggle Suara Button (Green / Muted Gray)
                          GestureDetector(
                            onTap: _toggleMute,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _isMuted ? Colors.grey.shade400 : Colors.green.shade500,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isMuted ? Colors.grey.shade600 : Colors.green.shade700,
                                    offset: const Offset(0, 3),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    _isMuted ? 'Mute' : 'Suara',
                                    style: GoogleFonts.fredoka(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const Spacer(),

                          // Page Indicator Box
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.assignment_rounded, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${_currentPageIndex + 1}/${_flatPages.length}',
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
                    ),
                  ),
                  
                  // GRID CONTENT
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _flatPages.length,
                      itemBuilder: (context, idx) {
                        final pageItem = _flatPages[idx];
                        
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(pageItem.page.rows.length, (r) {
                                  final row = pageItem.page.rows[r];
                                  final isTitleRow = (r == 0) && (pageItem.pageIndexInChapter == 0);
                                  
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: isTitleRow ? 8.0 : 3.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(row.length, (c) {
                                        final word = row[c];
                                        
                                        return WordBubble(
                                          item: word,
                                          fontSize: isTitleRow ? titleFontSize : gridFontSize,
                                          isHighlighted: false,
                                          onTap: () {
                                            if (!_isMuted) {
                                              String audioPath = word.audio;
                                              if (audioPath.isEmpty) {
                                                final typeStr = widget.type == ReadingType.konsonan ? 'Konsonan' : 'Sengau';
                                                final folderName = (widget.type == ReadingType.konsonan && pageItem.chapter.chapterNumber == 11)
                                                    ? 'Halaman 11'
                                                    : 'halaman ${pageItem.chapter.chapterNumber}';
                                                final cleanWord = word.text.trim().toLowerCase();
                                                audioPath = 'assets/audio/words/$typeStr/$folderName/$cleanWord.mp3';
                                              }
                                              _audioService.playAsset(audioPath);
                                            }
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
    if (_currentPageIndex == 0) return const SizedBox(width: 52); // Keep width for balance in portrait row
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
          color: Colors.blue.shade400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade900.withOpacity(0.2),
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
