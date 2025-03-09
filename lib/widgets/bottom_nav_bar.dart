import 'package:flutter/material.dart';
import 'package:zero_waste_project/pages/home_page.dart';
import 'package:zero_waste_project/pages/my_actions_list_page.dart';
import 'package:zero_waste_project/pages/profile_page.dart';
import 'package:zero_waste_project/pages/learn_how_to_act_page.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String id; // Changed type to String

  const BottomNavBar({required this.currentIndex, required this.id, Key? key}) : super(key: key);

  void onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage(id: id)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyActionsListPage(id: id)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(id: id)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LearnHowToActPage(id: id)),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => onTabTapped(context, index),
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF145740),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.camera),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'My Actions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: 'Learn',
        ),
      ],
    );
  }
}
