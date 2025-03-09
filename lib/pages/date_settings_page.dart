import 'package:flutter/material.dart';
import '../utils/date_utils.dart' as custom_utils;

class DateSettingsPage extends StatefulWidget {
  @override
  _DateSettingsPageState createState() => _DateSettingsPageState();
}

class _DateSettingsPageState extends State<DateSettingsPage> {
  DateTime _selectedDate = custom_utils.DateUtils.getToday();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Date'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Selected Date: ${custom_utils.DateUtils.formatDate(_selectedDate)}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Select Date'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                custom_utils.DateUtils.setMockDate(_selectedDate);
                Navigator.pop(context);
              },
              child: const Text('Set Date'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                custom_utils.DateUtils.resetMockDate();
                Navigator.pop(context);
              },
              child: const Text('Reset to Today'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
