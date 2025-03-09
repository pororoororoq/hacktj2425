import 'package:flutter/material.dart';
import 'search_result_page.dart';
import '../widgets/bottom_nav_bar.dart';

class SearchPage extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();
  final String id; // Changed type to String

  SearchPage({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white, // 바탕화면 색상 설정
      body: Container(
        color: Colors.white, // 여백 색상 설정
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Enter search term',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultPage(searchTerm: _searchController.text, id: id), // Keep id as String
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Search', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF145740),
                foregroundColor: Colors.white,
                minimumSize: const Size(150, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 0, id: id), // Keep id as String
    );
  }
}
