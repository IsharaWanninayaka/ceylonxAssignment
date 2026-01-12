import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'services/shared_pref_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/weather_service.dart';
import 'screens/weather_screen.dart';
import 'screens/add_edit_taskscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e, s) {
    debugPrint(e.toString());
    debugPrint(s.toString());
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<WeatherService>(create: (_) => WeatherService()),
        Provider<SharedPrefsService>(create: (_) => SharedPrefsService()),
      ],
      child: MaterialApp(
        title: 'TaskFlow',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => AppWrapper(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/profile': (context) => ProfileScreen(),
          '/register': (context) => RegisterScreen(),
          '/weather': (context) => WeatherScreen(),
          '/add-task': (context) => AddEditTaskScreen(),
        },
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final sharedPrefs = Provider.of<SharedPrefsService>(context, listen: false);

    return FutureBuilder<bool>(
      future: sharedPrefs.wasLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        sharedPrefs.saveLastOpenTime();
        final isLoggedInPrefs = snapshot.data ?? false;
        final isLoggedInFirebase = authService.isLoggedIn();

        return isLoggedInPrefs && isLoggedInFirebase
            ? HomeScreen()
            : LoginScreen();
      },
    );
  }
}
