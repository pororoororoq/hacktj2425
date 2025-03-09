import 'package:flutter/material.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../providers/user_data_provider.dart';
import '../utils/helpers_popup.dart';

class CameraResultPage extends StatefulWidget {
  final File image;
  final List<String> labels;
  final String id;

  const CameraResultPage({
    required this.image,
    required this.labels,
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  _CameraResultPageState createState() => _CameraResultPageState();
}

class _CameraResultPageState extends State<CameraResultPage> {
  List<List<dynamic>> _csvData = [];
  List<String> _dropdownOptions = [];
  String? _selectedItem;
  Map<String, String> _selectedItemData = {};
  final UserDataProvider _userDataProvider = UserDataProvider();
  List<Map<String, dynamic>> _myActionsList = [];

  @override
  void initState() {
    super.initState();
    debugPrint('CameraResultPage initialized with id: ${widget.id}');
    _loadCsvData();
    _initializeMyActionsList();
  }

  Future<void> _loadCsvData() async {
    try {
      final rawData = await rootBundle.loadString('assets/data/Zero_Waste.csv');
      List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
      setState(() {
        _csvData = listData;
        _dropdownOptions = _csvData
            .where((row) => widget.labels.any((label) => row[2].toString().contains(label)))
            .map((row) => row[2].toString())
            .toList();
      });
    } catch (e) {
      print('Error loading CSV data: $e');
    }
  }

  Future<void> _initializeMyActionsList() async {
    try {
      final actions = await _userDataProvider.getMyActionsList(widget.id);
      setState(() {
        _myActionsList = List<Map<String, dynamic>>.from(actions);
      });
    } catch (e) {
      print('Error initializing actions list: $e');
    }
  }

  void _onItemSelected(String? value) {
    if (value != null) {
      setState(() {
        _selectedItem = value;
        final selectedItemRow = _csvData.firstWhere((row) => row[2] == value);
        _selectedItemData = {
          'Image': selectedItemRow.length > 8 && selectedItemRow[8] != null ? selectedItemRow[8].toString() : '',
          'Category': selectedItemRow.length > 1 && selectedItemRow[0] != null && selectedItemRow[1] != null ? '${selectedItemRow[0]} / ${selectedItemRow[1]}' : '',
          'Item Name': selectedItemRow.length > 2 && selectedItemRow[2] != null ? selectedItemRow[2].toString() : '',
          'Disposal Category': selectedItemRow.length > 3 && selectedItemRow[3] != null ? selectedItemRow[3].toString() : '',
          'Cleaning/Preparation Steps': selectedItemRow.length > 4 && selectedItemRow[4] != null ? selectedItemRow[4].toString() : '',
          'Disposal Instructions': selectedItemRow.length > 5 && selectedItemRow[5] != null ? selectedItemRow[5].toString() : '',
          'Disposal Details': selectedItemRow.length > 9 && selectedItemRow[9] != null ? selectedItemRow[9].toString() : '',
          'Sustainable Alternatives': selectedItemRow.length > 6 && selectedItemRow[6] != null ? selectedItemRow[6].toString() : '',
          'Sustainable Details': selectedItemRow.length > 10 && selectedItemRow[10] != null ? selectedItemRow[10].toString() : '',
          'Environmental Impact': selectedItemRow.length > 7 && selectedItemRow[7] != null ? selectedItemRow[7].toString() : '',
        };
      });
    }
  }

  Future<void> _addToMyActionsList() async {
    try {
      final isExisting = _myActionsList.any((action) => action['title'] == _selectedItemData['Sustainable Alternatives']);

      if (isExisting) {
        throw Exception("There is already the action in your list");
      } else {
        final newAction = {
          'user_id': widget.id,
          'title': _selectedItemData['Sustainable Alternatives'] ?? '',
          'image': _selectedItemData['Image'] ?? '',
          'itemName': _selectedItemData['Item Name'] ?? '',
          'disposalCategory': _selectedItemData['Disposal Category'] ?? '',
        };

        await _userDataProvider.addMyActionslist(widget.id.toString(), newAction);
        debugPrint('Action added for id: ${widget.id}');

        final actions = await _userDataProvider.getMyActionsList(widget.id);
        debugPrint('Actions after addition: $actions');

        setState(() {
          _myActionsList = List<Map<String, dynamic>>.from(actions);
        });

        showStyledDialog(
          context: context,
          content: 'The action has been added\nto your actions list.',
          buttonText: 'To My Actions List',
          onButtonPressed: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, '/my_actions_list', arguments: {'id': widget.id.toString()});
          },
        );
      }
    } catch (e) {
      showStyledDialog(
        context: context,
        content: 'This action already exists in your list.',
        buttonText: 'To My Actions List',
        onButtonPressed: () {
          Navigator.of(context).pop();
          Navigator.pushNamed(context, '/my_actions_list', arguments: {'id': widget.id.toString()});
        },
      );
    }
  }

void _showDetails(String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white, // 다이얼로그 배경을 화이트로 설정
        content: SingleChildScrollView(
          child: Text(content),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF145740), // 텍스트 색상을 설정
            ),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Result', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedItem,
                    hint: const Text('Select an item'),
                    items: _dropdownOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: Text(
                            value,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: _onItemSelected,
                    dropdownColor: Colors.white,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(7.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.file(widget.image, width: 300, height: 300),
                    ),
                    if (_selectedItemData.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.0),
                            Text(_selectedItemData['Disposal Category'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                            SizedBox(height: 0),
                            Text(_selectedItemData['Item Name'] ?? '', style: Theme.of(context).textTheme.displayLarge),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity, // 최대 너비로 설정
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.0),
                                    spreadRadius: 0,
                                    blurRadius: 0,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Disposal Instructions', style: Theme.of(context).textTheme.titleLarge),
                                  SizedBox(height: 7.0),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${_selectedItemData['Cleaning/Preparation Steps'] ?? ''} and ${_selectedItemData['Disposal Instructions'] ?? ''} ',
                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.2),
                                        ),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              _showDetails(_selectedItemData['Disposal Details'] ?? 'No details available');
                                            },
                                            child: Text(
  '  >> see details', 
  style: TextStyle(
    color: Colors.grey,
    fontSize: 14,
  ),
),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              width: double.infinity, // 최대 너비로 설정
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.lightGreen.withOpacity(0.0),
                                    spreadRadius: 0,
                                    blurRadius: 0,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sustainable Action', style: Theme.of(context).textTheme.titleLarge),
                                  SizedBox(height: 7.0),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: _selectedItemData['Sustainable Alternatives'] ?? '',
                                          style: Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.2),
                                        ),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              _showDetails(_selectedItemData['Sustainable Details'] ?? 'No details available');
                                            },
                                            child: Text(
  '  >> see details', 
  style: TextStyle(
    color: Colors.grey,
    fontSize: 14,
  ),
),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 7.0),
                                  ElevatedButton(
                                    onPressed: _addToMyActionsList,
                                    child: const Text('Add My Actions List!', style: TextStyle(fontSize: 16)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF145740),
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(130, 40),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Container(
                              width: double.infinity, // 최대 너비로 설정
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.0),
                                    spreadRadius: 0,
                                    blurRadius: 0,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Action Impact', style: Theme.of(context).textTheme.titleLarge),
                                  SizedBox(height: 7.0),
                                  Text(
                                    _selectedItemData['Environmental Impact'] ?? '',
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(height: 1.2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
