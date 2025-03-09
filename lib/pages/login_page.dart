import 'package:flutter/material.dart';
import '../providers/user_data_provider.dart';
import '../models/user.dart';
import '../database/database_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserDataProvider _userDataProvider = UserDataProvider();
  final DatabaseService _databaseService = DatabaseService();

  Future<void> _loginUser(String email, String password) async {
    User? user = await _userDataProvider.getUserByEmail(email, password);

    if (user != null) {
      // 사용자가 존재할 때 처리
      debugPrint('Login successful with ID: ${user.id}'); 

      // checkAndResetDailyXP 함수 호출
      await _databaseService.checkAndResetDailyXP(user.id);

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {'id': user.id},
      );
    } else {
      // 사용자가 존재하지 않으면 로그인 실패 처리
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  Future<void> _handleSpecialLogin() async {
    const String specialEmail = 'apple@gmail.com';
    const String specialPassword = '1111';

    // 'apple@gmail.com'과 '1111'로 로그인할 때
    if (_emailController.text == specialEmail && _passwordController.text == specialPassword) {
      User? user = await _userDataProvider.getUserByEmail(specialEmail, specialPassword);

      if (user == null) {
        // 사용자 생성 로직
        String newUserId = await _userDataProvider.saveUser(
          username: 'Apple User',
          email: specialEmail,
          password: specialPassword,
          xp: 0,
          actionCount: 0,
          badges: [],
          completedActions: [],
        );
        user = await _userDataProvider.getUserById(newUserId);
      }

      // 새로 생성된 사용자 또는 기존 사용자로 로그인 처리
      await _loginUser(specialEmail, specialPassword);
    } else {
      // 일반적인 로그인 처리
      await _loginUser(_emailController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Container(
                color: Colors.white,
                child: Image.asset('assets/images/login.png', width: 550, height: 400),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await _handleSpecialLogin(); // apple@gmail.com과 1111 처리
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF145740),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(150, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF145740),
                  minimumSize: const Size(150, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFF145740)),
                  ),
                ),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
