import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/my_actions_list_page.dart';
import 'pages/profile_page.dart';
import 'pages/learn_how_to_act_page.dart';
import 'pages/camera_page.dart';
import 'pages/search_page.dart';
import 'pages/signup_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await deleteDatabaseFile(); // 데이터베이스 파일 삭제
  runApp(const MyApp());
}

// 데이터베이스 파일 삭제 함수
Future<void> deleteDatabaseFile() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'user_database.db');
  
  // 데이터베이스 파일 삭제
  await deleteDatabase(path);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zero Waste App',
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF145740),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Color(0xFF145740),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF145740)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF145740),
          unselectedItemColor: Colors.grey,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF145740),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF424242),
          ),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final args = settings.arguments as Map<String, dynamic>?;

        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (context) => SignUpPage());
          case '/home':
            if (args != null && args.containsKey('id')) {
              return MaterialPageRoute(builder: (context) => HomePage(id: args['id']));
            }
            return _errorRoute();
          case '/my_actions_list':
            if (args != null && args.containsKey('id')) {
              return MaterialPageRoute(builder: (context) => MyActionsListPage(id: args['id']));
            }
            return _errorRoute();
          case '/profile':
            if (args != null && args.containsKey('id')) {
              return MaterialPageRoute(builder: (context) => ProfilePage(id: args['id']));
            }
            return _errorRoute();
          case '/learn_how_to_act':
            if (args != null && args.containsKey('id')) {
              return MaterialPageRoute(builder: (context) => LearnHowToActPage(id: args['id']));
            }
            return _errorRoute();
          case '/camera':
            if (args != null && args.containsKey('id')) {
              return MaterialPageRoute(builder: (context) => CameraPage(id: args['id'])); // Pass id here
            }
            return _errorRoute();
          case '/search':
            if (args != null && args.containsKey('id')) {
              return MaterialPageRoute(builder: (context) => SearchPage(id: args['id'])); // Pass id here
            }
            return _errorRoute();
          default:
            return _errorRoute();
        }
      },
    );
  }

  Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found!'),
        ),
      );
    });
  }
}
