import 'package:flutter/material.dart';
import '../providers/user_data_provider.dart'; // 로그아웃 처리 관련 데이터 제공자
import 'login_page.dart'; // 로그인 페이지 import 추가
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/user_action.dart';
import '../models/daily_xp.dart';
import '../widgets/custom_badge.dart';
import '../widgets/custom_graph.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/csv_service.dart';
import '../providers/badge_provider.dart';
import '../database/database_service.dart';
import '../utils/date_utils.dart' as custom_date_utils;
import 'package:url_launcher/url_launcher.dart'; // Import the url_launcher package

class ProfilePage extends StatefulWidget {
  final String id;

  const ProfilePage({required this.id, Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserDataProvider _userDataProvider = UserDataProvider();
  final BadgeProvider _badgeProvider = BadgeProvider();
  late DatabaseService _databaseService;
  User? _user;
  List<UserAction> _completedActions = [];
  List<DailyXP> _dailyXP = [];
  List<CustomBadge> _badges = [];
  bool _isLoading = true;
  Map<String, int> _xpData = {};
  DateTime _creationDate = DateTime.now();
  late DateTime mockDate; // mockDate를 멤버 변수로 추가

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService(); // _databaseService 초기화
    mockDate = custom_date_utils.DateUtils.getToday(); // mockDate 초기화
    _loadUserData();
    _loadXPData();
  }

  Future<void> _loadXPData() async {
    final List<List<dynamic>> csvData = await CsvService().loadCsvData('assets/data/xp.csv');
    for (var row in csvData) {
      if (row.length > 1) {
        _xpData[row[0]] = int.tryParse(row[1].toString()) ?? 0;
      }
    }
  }

  Future<void> _loadUserData() async {
    DateTime currentDate = DateTime.now();
    DateTime mockDate = custom_date_utils.DateUtils.getToday();
    print('Profile Page - Current Date: $currentDate');
    print('Profile Page - Mock Date: $mockDate');

    User? user = await _userDataProvider.getUserById(widget.id);
    if (user != null) {
      List<CustomBadge> badges = _badgeProvider.getBadgesForXP(user.xp);
      List<UserAction> completedActions = await _userDataProvider.getCompletedActions(widget.id);
      List<DailyXP> dailyXP = await _databaseService.getDailyXP(widget.id);

      // getCompletedActions를 통해 가져온 데이터 출력
      print('Profile Page - Completed Actions:');
      for (var action in completedActions) {
        print('Title: ${action.title}, Count: ${action.count}, XP: ${action.xp}');
      }

      setState(() {
        _user = user;
        _badges = badges;
        _completedActions = completedActions;
        _dailyXP = dailyXP;
        _creationDate = user.creationDate;
        _isLoading = false;
      });

      print("Profile Page - Mock Date: $mockDate"); // 현재 설정된 날짜 프린트
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 로그아웃 메서드
  Future<void> _logout(BuildContext context) async {
    try {
      // 로그아웃 처리
      await _userDataProvider.logout();

      // 로그아웃 성공 시 로그인 페이지로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  Future<void> _deleteAccount() async {
    // 사용자의 데이터를 삭제하는 동작을 수행
    await _userDataProvider.deleteUser(widget.id);
    await _logout(context); // 삭제 후 로그아웃하면서 context 전달
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    bool result = await showStyledDialog(
      context: context,
      content: 'Are you sure you want to delete your account? This action cannot be undone.',
      buttonText: 'Delete',
      onButtonPressed: () {
        Navigator.of(context).pop(true); // Delete 버튼을 눌렀을 때 true 반환
      },
    );
    return result;
  }

  // URL launcher method to open links
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Progress', style: TextStyle(color: Color(0xFF145740))),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Progress', style: TextStyle(color: Color(0xFF145740))),
          backgroundColor: Colors.white,
        ),
        body: const Center(child: Text('유저 데이터를 불러오지 못했습니다.')),
      );
    }

    // 날짜 포맷팅
    String formattedCreationDate = DateFormat('MM/dd/yyyy').format(_creationDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Progress', style: TextStyle(color: Color(0xFF145740))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF145740)),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 300,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Hello, ${_user!.username}!',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF145740)),
                  ),
                ),
                const SizedBox(height: 0),
                Text('since $formattedCreationDate', style: TextStyle(fontSize: 12, color: Color(0xFF424242))),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 130,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF145740),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Count ${_user!.actionCount}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 130,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF145740),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Impact ${_user!.xp}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: List.generate(5, (index) {
                    if (index < _badges.length) {
                      CustomBadge badge = _badges[index];
                      return Image.asset(badge.imagePath, width: 65, height: 65);
                    } else {
                      return Image.asset('assets/images/badges/badge_coming.png', width: 65, height: 65);
                    }
                  }),
                ),
                const SizedBox(height: 30),
                _dailyXP.isNotEmpty
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        height: 220,
                        child: Center(
                          child: CustomGraph(
                            dailyXP: _dailyXP,
                            creationDate: _creationDate, // creationDate 전달
                            mockDate: mockDate, // mockDate를 전달
                          ),
                        ),
                      )
                    : Column(
                        children: const [
                          Text('No data available for the graph.'),
                          CircularProgressIndicator(),
                        ],
                      ),
                const SizedBox(height: 30),
                Divider(color: Colors.grey, thickness: 0.5),
                Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 60,
                            child: Container(
                              padding: const EdgeInsets.all(1.0),
                              child: const Text(
                                'Actions Completed',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 20,
                            child: Container(
                              padding: const EdgeInsets.all(1.0),
                              child: const Text(
                                'Count',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 20,
                            child: Container(
                              padding: const EdgeInsets.all(1.0),
                              child: const Text(
                                'Impact',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey, thickness: 0.5),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _completedActions.length,
                        itemBuilder: (context, index) {
                          UserAction action = _completedActions[index];
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 60,
                                    child: Container(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Text(action.title, style: TextStyle(fontSize: 16, height: 1.2)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Text('${action.count}', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 20,
                                    child: Container(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Text('${action.xp}', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.grey, thickness: 0.5),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),

                // Logout and Delete Account buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 로그아웃 버튼
                    Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFF145740), width: 0.5),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          // 로그아웃 처리
                          await _logout(context); // context 전달
                        },
                        child: Text(
                          'Log out',
                          style: TextStyle(color: Color(0xFF145740), fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // 버튼 간의 간격
                    // 계정 삭제 버튼
                    Container(
                      width: 160,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFF145740), width: 0.5),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          // 계정 삭제 확인 알림창 표시
                          bool confirmDelete = await _showDeleteConfirmationDialog();
                          if (confirmDelete) {
                            // 계정 삭제 동작
                            await _deleteAccount();
                            Navigator.pushReplacementNamed(context, '/'); // 로그인 화면으로 이동
                          }
                        },
                        child: Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 추가된 중앙 정렬 문구 부분 with clickable links
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _launchURL('mailto:jakekim070917@gmail.com'),
                        child: Text(
                          'jakekim070917@gmail.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _launchURL('https://sites.google.com/view/green-savvy'),
                        child: Text(
                          'https://sites.google.com/view/green-savvy',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      Text(
                        'Copyright © 2024 Green Savvy. All Rights Reserved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 2, id: widget.id),
    );
  }
}

// 다이얼로그 함수 - 반환 타입을 bool로 수정하여 true/false 반환
Future<bool> showStyledDialog({
  required BuildContext context,
  required String content,
  String buttonText = 'OK',
  VoidCallback? onButtonPressed,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // 화이트 배경
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              content,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text(
              buttonText,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            onPressed: () {
              if (onButtonPressed != null) {
                onButtonPressed();
              } else {
                Navigator.of(context).pop(true); // 다이얼로그 닫히며 true 반환
              }
            },
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // 반환 값이 null이면 false 반환
}
