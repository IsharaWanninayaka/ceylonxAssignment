import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constant.dart';

class SharedPrefsService {
  // Save last app open time
  Future<void> saveLastOpenTime() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(AppConstants.lastOpenTimeKey, now);
  }

  // Get last app open time
  Future<String?> getLastOpenTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.lastOpenTimeKey);
  }

  // Get saved email
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userEmailKey);
  }

  // Check if user was logged in
  Future<bool> wasLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }
}
