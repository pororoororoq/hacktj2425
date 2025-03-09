import 'package:flutter/material.dart';
import '../widgets/custom_badge.dart';
import '../providers/user_data_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/csv_service.dart';
import '../models/user_action.dart';
import 'package:zero_waste_project/utils/helpers_popup.dart' as helpersPopup; // helpers_popup.dart에 별칭 helpersPopup 사용
import 'package:zero_waste_project/pages/profile_page.dart' as profilePage; // profile_page.dart에 별칭 profilePage 사용
import 'package:zero_waste_project/utils/helpers_popup.dart' as helpers;

class MyActionsListPage extends StatefulWidget {
  final String id;

  const MyActionsListPage({required this.id, Key? key}) : super(key: key);

  @override
  _MyActionsListPageState createState() => _MyActionsListPageState();
}

class _MyActionsListPageState extends State<MyActionsListPage> {
  final UserDataProvider _userDataProvider = UserDataProvider();
  final CsvService _csvService = CsvService();
  Map<String, int> _xpData = {};
  List<Map<String, dynamic>> _actions = [];
  List<UserAction> _userActions = [];
  Map<String, String> _impactData = {};
  Map<String, String> _sustainableDetailsData = {}; // sustainable details 데이터를 저장할 맵

  @override
  void initState() {
    super.initState();
    debugPrint('MyActionsListPage initialized with id: ${widget.id}');
    _loadMyActionsList();
    _loadXPData();
    _loadUserActions(); // _userActions도 로드
    _loadImpactData(); // Impact 데이터를 로드
    _loadSustainableDetailsData(); // Sustainable details 데이터를 로드
  }

  Future<void> _loadXPData() async {
    final List<List<dynamic>> csvData = await _csvService.loadCsvData('assets/data/xp.csv');
    for (var row in csvData) {
      if (row.length > 1) {
        _xpData[row[0]] = int.tryParse(row[1].toString()) ?? 0;
      }
    }
  }

  Future<void> _loadImpactData() async {
    final List<List<dynamic>> csvData = await _csvService.loadCsvData('assets/data/Zero_Waste.csv');
    for (var row in csvData) {
      if (row.length > 7) {
        _impactData[row[6]] = row[7].toString(); // Sustainable Alternatives을 key로, Environmental Impact를 value로 저장
      }
    }
  }

  Future<void> _loadSustainableDetailsData() async {
    final List<List<dynamic>> csvData = await _csvService.loadCsvData('assets/data/Zero_Waste.csv');
    for (var row in csvData) {
      if (row.length > 10) {
        _sustainableDetailsData[row[6]] = row[10].toString(); // Sustainable Alternatives을 key로, Sustainable Details을 value로 저장
      }
    }
  }

  Future<void> _loadMyActionsList() async {
    debugPrint('Loading actions for user id: ${widget.id}');
    final actions = await _userDataProvider.getMyActionsList(widget.id);
    debugPrint('My Actions Loaded: $actions');
    final filteredActions = actions
        .where((action) =>
            action['image'] != null &&
            action['itemName'] != null &&
            action['disposalCategory'] != null &&
            action['title'] != null)
        .toList();

    // 중복 제거
    final uniqueActions = filteredActions.toSet().toList();
    debugPrint('Filtered Unique Actions: $uniqueActions');

    if (mounted) {
      setState(() {
        _actions = uniqueActions;
      });
    }
  }

  Future<void> _loadUserActions() async {
    debugPrint('Loading user actions for user id: ${widget.id}');
    final actions = await _userDataProvider.getActions(widget.id);
    debugPrint('User Actions Loaded: $actions');
    if (mounted) {
      setState(() {
        _userActions = actions;
      });
    }
  }

void _showXPDialog(int xp) {
    helpersPopup.showStyledDialog(  // helpers_popup.dart의 함수 사용
      context: context,
      content: 'Action completed.\nYou\'ve got $xp XP.',
      buttonText: 'To See My Progress',
      onButtonPressed: () {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => profilePage.ProfilePage(id: widget.id),  // profile_page.dart의 ProfilePage 사용
          ),
        );
      },
    );
}


  Future<void> _showBadgePopup(CustomBadge badge) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // 화이트 바탕화면
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(badge.imagePath, width: 50, height: 50),
              Text(
                badge.name,
                style: Theme.of(context).textTheme.titleLarge, // 텍스트 스타일 설정
              ),
              const SizedBox(height: 10),
              Text(
                'You\'ve earned a new badge!',
                style: Theme.of(context).textTheme.titleLarge, // 텍스트 스타일 설정
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: Theme.of(context).textTheme.headlineMedium, // 버튼 텍스트 스타일 설정
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _onActionButtonPressed(Map<String, dynamic> action) async {
    String title = action['title'];
    String image = action['image'];
    int xp = _xpData[title] ?? 0;

    List<CustomBadge> newBadges = await _userDataProvider.handleActionButtonPressed(
      id: widget.id,
      title: title,
      image: image,
      xp: xp,
    );

    _loadUserActions();

    // XP 팝업 표시
    _showXPDialog(xp);

    // 새로운 뱃지 팝업 표시
    if (newBadges.isNotEmpty) {
      for (CustomBadge badge in newBadges) {
        await _showBadgePopup(badge);
      }
    } else {
      debugPrint('No new badges earned.');
    }
  }

void _showDetails(String title) {
  String details = _sustainableDetailsData[title] ?? 'No details available';
  helpers.showStyledDialog(  // helpers 별칭을 사용하여 호출
    context: context,
    content: details,
    buttonText: 'Close',
    onButtonPressed: null,  // 기본 동작으로 다이얼로그 닫기
  );
}

void _showImpactDialog(String title) {
  String impact = _impactData[title] ?? 'No impact data available';
  helpers.showStyledDialog(  // helpers 별칭을 사용하여 호출
    context: context,
    content: impact,
    buttonText: 'Close',
    onButtonPressed: null,  // 기본 동작으로 다이얼로그 닫기
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Actions List', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Center(
            child: Column(
              children: [
                _actions.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Here, you will find the Sustainable Actions for the items you have searched for using the Camera and Search features.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _actions.length,
                        itemBuilder: (context, index) {
                          final action = _actions[index];
                          int xp = _xpData[action['title']] ?? 0;
                          return Column(
                            children: [
                              if (action['image'] != null &&
                                  action['itemName'] != null &&
                                  action['disposalCategory'] != null &&
                                  action['title'] != null)
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(left: 0),
                                        width: MediaQuery.of(context).size.width * 0.33,
                                        height: 170,
                                        child: action['image'] != null &&
                                                action['image'].isNotEmpty
                                            ? Image.asset(action['image'], fit: BoxFit.contain)
                                            : Container(color: Colors.grey),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.57,
                                        padding: const EdgeInsets.only(left: 10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(action['disposalCategory'] ?? '',
                                                style: Theme.of(context).textTheme.bodyLarge),
                                            Text(action['itemName'] ?? '',
                                                style: Theme.of(context).textTheme.displayLarge),
                                            SizedBox(height: 7.0),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: action['title'] ?? '',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .copyWith(height: 1.2),
                                                  ),
                                                  WidgetSpan(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        _showDetails(action['title'] ?? 'No details available');
                                                      },
                                                      child: Text(' >> see details',
                                                          style: TextStyle(color: Colors.grey)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 7.0),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () => _onActionButtonPressed(action),
                                                    style: ElevatedButton.styleFrom(
                                                      padding: EdgeInsets.symmetric(horizontal: 7.0),
                                                      backgroundColor: const Color(0xFF145740),
                                                      foregroundColor: Colors.white,
                                                      minimumSize: const Size(50, 40),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                    child: const Text('Action!',
                                                        style: TextStyle(
                                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                                  ),
                                                ),
                                                SizedBox(width: 10), // 적절한 간격 추가
                                                Expanded(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      _showImpactDialog(action['title']);
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      padding: EdgeInsets.symmetric(horizontal: 7.0),
                                                      backgroundColor: Colors.white, // 배경색을 화이트로 설정
                                                      minimumSize: const Size(70, 40),
                                                      side: const BorderSide(color: Color(0xFF145740)), // 테두리 색을 설정
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      'Impact: $xp',
                                                      style: const TextStyle(
                                                          color: Color(0xFF145740),
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold),
                                                      overflow: TextOverflow.visible,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(),
                              const Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                                indent: 8,
                                endIndent: 8,
                              ),
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 1, id: widget.id),
    );
  }
}
