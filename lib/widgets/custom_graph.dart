import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/daily_xp.dart';
import '../utils/date_utils.dart' as custom_date_utils;

class CustomGraph extends StatelessWidget {
  final List<DailyXP> dailyXP;
  final DateTime creationDate;
  final DateTime mockDate;

  CustomGraph({
    required this.dailyXP,
    required this.creationDate,
    required this.mockDate,
    Key? key,
  }) : super(key: key);

  List<FlSpot> _generateDataPoints(DateTime startDate, DateTime endDate) {
    List<FlSpot> spots = [];
    double cumulativeXP = 0;

    DateTime date = startDate;

    // 종료 날짜를 포함하도록 수정
    while (!date.isAfter(endDate)) {
      String dateString = custom_date_utils.DateUtils.formatDate(date);
      DailyXP dailyXPEntry = dailyXP.firstWhere(
        (xp) => xp.date == dateString,
        orElse: () => DailyXP(dailyXpId: 0, userId: '', date: dateString, xp: 0),
      );
      print("GraphDate: $dateString, GraphDailyXPEntry: $dailyXPEntry");
      cumulativeXP += dailyXPEntry.xp;
      spots.add(FlSpot(date.difference(startDate).inDays.toDouble(), cumulativeXP));
      date = date.add(Duration(days: 1));
    }

    // 만약 데이터 포인트가 없을 경우 기본 포인트 추가
    if (spots.isEmpty) {
      spots = [FlSpot(0, 0)];
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime(creationDate.year, creationDate.month, creationDate.day); // 시간 제거
    DateTime endDate = DateTime(creationDate.year, creationDate.month, creationDate.day).add(const Duration(days: 30));

    // 데이터가 있는 마지막 날짜 계산
    if (dailyXP.isNotEmpty) {
      DateTime lastDataDate = DateTime.parse(dailyXP.last.date);
      if (lastDataDate.isAfter(endDate)) {
        endDate = DateTime(lastDataDate.year, lastDataDate.month, lastDataDate.day); // 시간 제거 후 비교
      }
    }

    // 만약 mockDate가 데이터의 마지막 날짜보다 늦을 경우, 그 날짜까지 확장
    if (mockDate.isAfter(endDate)) {
      endDate = DateTime(mockDate.year, mockDate.month, mockDate.day); // 시간 제거
    }

    List<FlSpot> spots = _generateDataPoints(startDate, endDate);
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    if (maxY < 500) {
      maxY = 500;
    } else {
      maxY = (maxY ~/ 100 + 1) * 100; // 최댓값을 100단위로 반올림
    }

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            barWidth: 2,
            color: const Color(0xFF145740),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF145740).withOpacity(0.3),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                DateTime date = startDate.add(Duration(days: value.toInt()));
                String formattedDate = '${date.month}/${date.day}';
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(formattedDate, style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                );
              },
              interval: 100,
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
        minY: 0,
        maxY: maxY,
      ),
    );
  }
}

class DateUtils {
  static DateTime _mockDate = DateTime.now();

  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime getToday() {
    print('getToday() called: $_mockDate');
    return DateTime(_mockDate.year, _mockDate.month, _mockDate.day); // 시간 제거 후 반환
  }

  static void setMockDate(DateTime date) {
    _mockDate = DateTime(date.year, date.month, date.day); // 시간 제거
    print('setMockDate() called: $date');
  }

  static void resetMockDate() {
    _mockDate = DateTime.now();
    print('resetMockDate() called: $_mockDate');
  }
}
