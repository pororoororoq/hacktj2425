import 'package:flutter/material.dart';
import '../providers/user_data_provider.dart';
import 'camera_page.dart';
import 'search_page.dart';
import '../widgets/bottom_nav_bar.dart';
import 'date_settings_page.dart'; // 날짜 설정 페이지 import 추가

class HomePage extends StatefulWidget {
  final String id;

  const HomePage({Key? key, required this.id}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<String> userName;

  @override
  void initState() {
    super.initState();
    debugPrint('HomePage initialized with id: ${widget.id}');
    userName = _getUserName();
  }

  Future<String> _getUserName() async {
    final userDataProvider = UserDataProvider();
    final user = await userDataProvider.getUserById(widget.id);
    return user?.username ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Image.asset('assets/images/logo.png', width: 400),
              const SizedBox(height: 20),
              const Text(
                'Environmental sustainability',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF145740),
                ),
              ),
              const SizedBox(height: 3),
              FutureBuilder<String>(
                future: userName,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading user name');
                  } else {
                    return Text(
                      'Welcome, ${snapshot.data}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF145740),
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 15),
              const Text(
                'What Goes Where?',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF145740),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('Navigating to CameraPage with id: ${widget.id}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CameraPage(id: widget.id)),
                      );
                    },
                    icon: const Icon(Icons.camera),
                    label: const Text('Take Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF145740),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('Navigating to SearchPage with id: ${widget.id}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPage(id: widget.id)),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Search', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF145740),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(140, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 0),
              Image.asset('assets/images/home_image.png', width: 450, height: 400),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  debugPrint('Navigating to DateSettingsPage with id: ${widget.id}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DateSettingsPage()),
                  );
                },
                icon: const Icon(Icons.date_range),
                label: const Text('Set Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF145740),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(140, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0, id: widget.id),
    );
  }
}
