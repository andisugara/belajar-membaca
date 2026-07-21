class Chapter {
  final String id;
  final int chapterNumber;
  final String title;
  final String description;
  final List<ChapterPage> pages;

  Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.pages,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      chapterNumber: json['chapter_number'] as int,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      pages: (json['pages'] as List<dynamic>)
          .map((p) => ChapterPage.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ChapterPage {
  final int pageNumber;
  final String pageAudio;
  final List<List<WordItem>> rows;

  ChapterPage({
    required this.pageNumber,
    required this.pageAudio,
    required this.rows,
  });

  factory ChapterPage.fromJson(Map<String, dynamic> json) {
    var rowsJson = json['rows'] as List<dynamic>;
    List<List<WordItem>> parsedRows = rowsJson.map((row) {
      return (row as List<dynamic>)
          .map((item) => WordItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }).toList();

    return ChapterPage(
      pageNumber: json['page_number'] as int,
      pageAudio: (json['page_audio'] as String?) ?? '',
      rows: parsedRows,
    );
  }
}

class WordItem {
  final String text;
  final List<String> syllables;
  final List<String>? colors;
  final String audio;

  WordItem({
    required this.text,
    required this.syllables,
    this.colors,
    required this.audio,
  });

  factory WordItem.fromJson(Map<String, dynamic> json) {
    return WordItem(
      text: json['text'] as String,
      syllables: (json['syllables'] as List<dynamic>).map((s) => s as String).toList(),
      colors: json['colors'] != null
          ? (json['colors'] as List<dynamic>).map((c) => c as String).toList()
          : null,
      audio: (json['audio'] as String?) ?? '',
    );
  }
}
