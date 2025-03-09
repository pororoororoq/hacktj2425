import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/my_actions_list_page.dart';
import 'pages/profile_page.dart';
import 'pages/learn_how_to_act_page.dart';
import 'pages/camera_page.dart';
import 'pages/search_page.dart';
import 'pages/signup_page.dart';
import 'pages/date_settings_page.dart'; // 새로 추가된 페이지
import 'database/database_service.dart'; // 패키지 추가
import 'utils/date_utils.dart'; // 패키지 추가

void main() async {
  WidgetsApp.showPerformanceOverlayOverride = false;  // Disable the performance overlay globally
  WidgetsFlutterBinding.ensureInitialized();
  final databaseService = DatabaseService();

  // 사용자 ID를 가져오는 로직이 필요합니다. 예를 들어, 로그인 후 저장된 사용자 ID를 불러옵니다.
  String userId = '사용자 ID'; // 실제 사용자 ID로 대체 필요

  // checkAndResetDailyXP 함수 호출
  await databaseService.checkAndResetDailyXP(userId);

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Savvy',
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF145740),
        scaffoldBackgroundColor: Colors.white, // 전체 바탕화면 및 여백 컬러를 화이트로 설정
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
          displayLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
          headlineLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF145740),
          ),
          headlineMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFF145740),
          ),
          titleLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            color: Color(0xFF424242),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF145740),
          ),
          labelMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF145740),
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF424242),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF424242),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF145740)),
          ),
          floatingLabelStyle: TextStyle(color: Color(0xFF145740)),
          labelStyle: TextStyle(color: Color(0xFF145740)),
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
              return MaterialPageRoute(builder: (context) => CameraPage(id: args['id']));
            }
            return _errorRoute();
          case '/search':
            if (args != null && args.containsKey('id')) {
              return MaterialPageRoute(builder: (context) => SearchPage(id: args['id']));
            }
            return _errorRoute();
          case '/date_settings':
            return MaterialPageRoute(builder: (context) => DateSettingsPage());
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
