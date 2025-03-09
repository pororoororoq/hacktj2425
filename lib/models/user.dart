class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final DateTime creationDate;  // 가입 날짜 필드
  final int xp;
  final int actionCount;
  final List<String> badges;
  final List<String> completedActions;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.creationDate,  // 가입 날짜 필드 초기화
    required this.xp,
    required this.actionCount,
    required this.badges,
    required this.completedActions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'creationDate': creationDate.toIso8601String(),  // 가입 날짜 변환
      'xp': xp,
      'actionCount': actionCount,
      'badges': badges.join(','),  // 리스트를 문자열로 변환
      'completedActions': completedActions.join(','),  // 리스트를 문자열로 변환
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      creationDate: DateTime.parse(map['creationDate']),  // 가입 날짜 변환
      xp: map['xp'],
      actionCount: map['actionCount'],
      badges: map['badges'].split(','),  // 문자열을 리스트로 변환
      completedActions: map['completedActions'].split(','),  // 문자열을 리스트로 변환
    );
  }

  List<String> getBadgesList() {
    return badges;
  }

  User addBadge(String badge) {
    List<String> badgesList = List.from(badges);
    badgesList.add(badge);
    return copyWith(badges: badgesList);
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    DateTime? creationDate,
    int? xp,
    int? actionCount,
    List<String>? badges,
    List<String>? completedActions,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      creationDate: creationDate ?? this.creationDate,  // creationDate 필드 할당
      xp: xp ?? this.xp,
      actionCount: actionCount ?? this.actionCount,
      badges: badges ?? this.badges,
      completedActions: completedActions ?? this.completedActions,
    );
  }
}
