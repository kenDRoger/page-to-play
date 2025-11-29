import 'package:shared_preferences/shared_preferences.dart';

class LocalUserService {
  static const String _uploadedEbooksKey = 'uploadedEbooks';

  Future<List<String>> getUploadedEbookIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_uploadedEbooksKey) ?? [];
  }

  Future<void> addUploadedEbookId(String ebookId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getUploadedEbookIds();
    if (!ids.contains(ebookId)) {
      ids.add(ebookId);
      await prefs.setStringList(_uploadedEbooksKey, ids);
    }
  }

  Future<void> removeUploadedEbookId(String ebookId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getUploadedEbookIds();
    if (ids.contains(ebookId)) {
      ids.remove(ebookId);
      await prefs.setStringList(_uploadedEbooksKey, ids);
    }
  }
}
