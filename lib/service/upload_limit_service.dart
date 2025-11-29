import 'package:shared_preferences/shared_preferences.dart';

class UploadLimitService {
  static const String _uploadCountKey = 'uploadCount';
  static const String _lastUploadDateKey = 'lastUploadDate';
  static const int _dailyUploadLimit = 5;

  Future<bool> canUpload() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUploadDateStr = prefs.getString(_lastUploadDateKey);
    final uploadCount = prefs.getInt(_uploadCountKey) ?? 0;

    if (lastUploadDateStr == null) {
      return true;
    }

    final lastUploadDate = DateTime.parse(lastUploadDateStr);
    final now = DateTime.now();
    final isSameDay = now.year == lastUploadDate.year &&
        now.month == lastUploadDate.month &&
        now.day == lastUploadDate.day;

    if (isSameDay) {
      return uploadCount < _dailyUploadLimit;
    }

    return true;
  }

  Future<void> incrementUploadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastUploadDateStr = prefs.getString(_lastUploadDateKey);
    int uploadCount = prefs.getInt(_uploadCountKey) ?? 0;

    if (lastUploadDateStr != null) {
      final lastUploadDate = DateTime.parse(lastUploadDateStr);
      final isSameDay = now.year == lastUploadDate.year &&
          now.month == lastUploadDate.month &&
          now.day == lastUploadDate.day;

      if (isSameDay) {
        uploadCount++;
      } else {
        uploadCount = 1;
      }
    } else {
      uploadCount = 1;
    }

    await prefs.setInt(_uploadCountKey, uploadCount);
    await prefs.setString(_lastUploadDateKey, now.toIso8601String());
  }

  Future<int> getRemainingUploads() async {
    if (await canUpload()) {
      final prefs = await SharedPreferences.getInstance();
      final uploadCount = prefs.getInt(_uploadCountKey) ?? 0;
      final lastUploadDateStr = prefs.getString(_lastUploadDateKey);

      if (lastUploadDateStr == null) {
        return _dailyUploadLimit;
      }

      final lastUploadDate = DateTime.parse(lastUploadDateStr);
      final now = DateTime.now();
      final isSameDay = now.year == lastUploadDate.year &&
          now.month == lastUploadDate.month &&
          now.day == lastUploadDate.day;

      if (isSameDay) {
        return _dailyUploadLimit - uploadCount;
      } else {
        return _dailyUploadLimit;
      }
    }
    return 0;
  }
}
