class DailyXP {
  final int dailyXpId;
  final String userId;
  final String date;
  final int xp;

  DailyXP({
    required this.dailyXpId,
    required this.userId,
    required this.date,
    required this.xp,
  });

  DailyXP copyWith({
    int? dailyXpId,
    String? userId,
    String? date,
    int? xp,
  }) {
    return DailyXP(
      dailyXpId: dailyXpId ?? this.dailyXpId,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      xp: xp ?? this.xp,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'daily_xp_id': dailyXpId,
      'user_id': userId,
      'date': date,
      'xp': xp,
    };
    print('DailyXP.toMap: $map'); // 로그 추가
    return map;
  }

  static DailyXP fromMap(Map<String, dynamic> map) {
    return DailyXP(
      dailyXpId: map['daily_xp_id'],
      userId: map['user_id'],
      date: map['date'],
      xp: map['xp'],
    );
  }

  @override
  String toString() {
    return 'DailyXP(dailyXpId: $dailyXpId, userId: $userId, date: $date, xp: $xp)';
  }
}
