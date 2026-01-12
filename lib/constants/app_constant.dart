import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static const String appName = 'TaskList';

  // Firebase collections
  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';

  // Shared Preferences keys
  static const String isLoggedInKey = 'isLoggedIn';
  static const String lastOpenTimeKey = 'lastOpenTime';
  static const String userEmailKey = 'userEmail';

  // Weather API
  static String get weatherApiKey {
    return dotenv.env['WEATHER_API_KEY'] ?? '';
  } // openweathermap.org

  static const String weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';
}
