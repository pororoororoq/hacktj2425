import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart'; // Google Maps를 열기 위한 패키지
import '../widgets/bottom_nav_bar.dart';
import 'search_result_page.dart'; // SearchResultPage import 추가

class LearnHowToActPage extends StatefulWidget {
  final String id;

  const LearnHowToActPage({Key? key, required this.id}) : super(key: key);

  @override
  _LearnHowToActPageState createState() => _LearnHowToActPageState();
}

class _LearnHowToActPageState extends State<LearnHowToActPage> {
  List<List<dynamic>> _zeroWasteData = [];
  List<List<dynamic>> _sitesData = [];

  @override
  void initState() {
    super.initState();
    _loadCsvData();
    _loadSitesData();
  }

  Future<void> _loadCsvData() async {
    final rawData = await rootBundle.loadString('assets/data/Zero_Waste.csv');
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    setState(() {
      _zeroWasteData = listData;
    });
  }

  Future<void> _loadSitesData() async {
    final rawData = await rootBundle.loadString('assets/data/sites.csv');
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
    setState(() {
      _sitesData = listData;
    });
  }

  void _showZeroWasteList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Disposal Instruction and Sustainable Action/Impact',
          style: TextStyle(color: Color(0xFF424242), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 10,
            columns: const [
              DataColumn(label: Text('Category', style: TextStyle(color: Color(0xFF145740), fontSize: 16, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Category2', style: TextStyle(color: Color(0xFF145740), fontSize: 16, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Item Name', style: TextStyle(color: Color(0xFF145740), fontSize: 16, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Disposal Category', style: TextStyle(color: Color(0xFF145740), fontSize: 16, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Cleaning/Preparation Steps', style: TextStyle(color: Color(0xFF145740), fontSize: 16, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Disposal Instructions', style: TextStyle(color: Color(0xFF145740), fontSize: 16, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Sustainable Alternatives', style: TextStyle(color: Color(0xFF145740), fontSize: 16, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Environmental Impact', style: TextStyle(color: Color(0xFF145740), fontSize: 16, fontWeight: FontWeight.bold))),
            ],
            rows: _zeroWasteData.map((row) {
              return DataRow(cells: [
                DataCell(Text(row[0].toString())),
                DataCell(Text(row[1].toString())),
                DataCell(Text(row[2].toString())),
                DataCell(Text(row[3].toString())),
                DataCell(Text(row[4].toString())),
                DataCell(Text(row[5].toString())),
                DataCell(Text(row[6].toString())),
                DataCell(Text(row[7].toString())),
              ]);
            }).toList(),
            border: TableBorder.symmetric(
              inside: BorderSide(color: Colors.grey, width: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  void _showSitesList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hazardous Waste Collection Sites List',
          style: TextStyle(color: Color(0xFF145740), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: _sitesData.sublist(1).map((site) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    site[4], // Types of Waste Accepted
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    site[0], // Facility Name
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(site[1]), // Address
                              Text(site[2]), // Contact Information
                              Text(site[3]), // Hours of operation
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Image.asset('assets/images/map.png', width: 24, height: 24),
                          onPressed: () => _openGoogleMaps(site[1]),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _navigateToSearchResultPage(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultPage(id: widget.id, filterCategory: category),
      ),
    );
  }

  void _openGoogleMaps(String address) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$address';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn How To Act', style: TextStyle(color: Color(0xFF145740))),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF145740)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Disposal Instruction',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
              ),
              const Text(
                'Sustainable Action/Impact',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                children: [
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Plastic'),
                    child: _buildGridItem('assets/images/learn1.png', 'Plastic'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Glass'),
                    child: _buildGridItem('assets/images/learn2.png', 'Glass'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Paper'),
                    child: _buildGridItem('assets/images/learn3.png', 'Paper'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Cardboard'),
                    child: _buildGridItem('assets/images/learn4.png', 'Cardboard'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Metal'),
                    child: _buildGridItem('assets/images/learn5.png', 'Metal'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Electronics'),
                    child: _buildGridItem('assets/images/learn6.png', 'Electronics'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Food'),
                    child: _buildGridItem('assets/images/learn7.png', 'Food'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Clothing'),
                    child: _buildGridItem('assets/images/learn8.png', 'Clothing'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Medication'),
                    child: _buildGridItem('assets/images/learn9.png', 'Medication'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Yard Waste'),
                    child: _buildGridItem('assets/images/learn10.png', 'Yard Waste'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Wooden'),
                    child: _buildGridItem('assets/images/learn11.png', 'Wooden'),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToSearchResultPage('Ceramic'),
                    child: _buildGridItem('assets/images/learn12.png', 'Ceramic'),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Drop off location',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
              ),
              const SizedBox(height: 10),
              const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
              const SizedBox(height: 10),
              ..._sitesData.sublist(1).map((site) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      site[0], // Facility Name
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      site[3], // Types of Waste Accepted
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    
                    const SizedBox(height: 10),
 Container(
  padding: const EdgeInsets.only(left: 10.0, top: 10, bottom: 10),
  decoration: BoxDecoration(
    color: Colors.grey[200],
    borderRadius: BorderRadius.circular(10),
  ),
  child: Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬 설정
          children: [
            Text(
              site[1], // Address
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              site[2], // Contact Information
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              site[4], // Types of Waste Accepted
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      IconButton(
        icon: Image.asset('assets/images/map.png', width: 40, height: 40),
        onPressed: () => _openGoogleMaps(site[1]),
      ),
    ],
  ),
),


                    const SizedBox(height: 20),
                    const Divider(
                      color: Colors.grey,
                      thickness: 0.5,
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3, id: widget.id.toString()),
    );
  }

  Widget _buildGridItem(String imagePath, String label) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 70, height: 70),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF424242)),
          ),
        ],
      ),
    );
  }
}
