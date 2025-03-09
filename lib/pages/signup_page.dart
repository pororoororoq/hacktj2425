import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../providers/user_data_provider.dart';
import '../models/user.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final UserDataProvider _userDataProvider = UserDataProvider();
  final Uuid _uuid = Uuid(); // Uuid 인스턴스 추가

  SignUpPage({Key? key}) : super(key: key);

  Future<void> _saveUser(BuildContext context) async {
    if (_passwordController.text == _confirmPasswordController.text) {
      final user = User(
        id: _uuid.v4(), // ID를 UUID로 생성
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        creationDate: DateTime.now(),
        xp: 0,
        actionCount: 0,
        badges: [],
        completedActions: [],
      );

      // saveUser 함수를 호출하여 데이터베이스에 사용자 삽입
      String id = await _userDataProvider.saveUser(
        username: user.username,
        email: user.email,
        password: user.password,
        creationDate: DateTime.now(),
        xp: 0,
        actionCount: 0,
        badges: [],
        completedActions: [],
      );

      print('User registered with ID: $id'); // 디버그 로그 추가
      if (id.isNotEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registered successfully')),
        );
        Navigator.pushReplacementNamed(context, '/', arguments: {'id': id}); // 로그인 페이지로 이동할 때 id 전달
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registration failed')),
        );
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
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
                child: Image.asset('assets/images/signup.png', width: 550, height: 400),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8.0),
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
              const SizedBox(height: 8.0),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _saveUser(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF145740),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(150, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
