// csv_service.dart
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class CsvService {
  Future<List<List<dynamic>>> loadCsvData(String path) async {
    final rawData = await rootBundle.loadString(path);
    List<List<dynamic>> listData = CsvToListConverter().convert(rawData);
    return listData;
  }
}
