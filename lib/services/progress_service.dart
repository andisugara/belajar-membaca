import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _keyLastChapter = 'last_chapter_id';
  static const String _keyLastPage = 'last_page_index';

  static Future<void> saveProgress(String chapterId, int pageIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastChapter, chapterId);
    await prefs.setInt(_keyLastPage, pageIndex);
  }

  static Future<Map<String, dynamic>?> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final chapterId = prefs.getString(_keyLastChapter);
    final pageIndex = prefs.getInt(_keyLastPage);
    
    if (chapterId != null && pageIndex != null) {
      return {
        'chapterId': chapterId,
        'pageIndex': pageIndex,
      };
    }
    return null;
  }

  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastChapter);
    await prefs.remove(_keyLastPage);
  }
}
