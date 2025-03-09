class UserAction {
  int action_id;
  String user_id;
  String title;
  String image;
  int count;
  int xp;

  UserAction({
    required this.action_id,
    required this.user_id,
    required this.title,
    required this.image,
    required this.count,
    required this.xp,
  });

  UserAction copyWith({
    int? action_id,
    String? user_id,
    String? title,
    String? image,
    int? count,
    int? xp,
  }) {
    return UserAction(
      action_id: action_id ?? this.action_id,
      user_id: user_id ?? this.user_id,
      title: title ?? this.title,
      image: image ?? this.image,
      count: count ?? this.count,
      xp: xp ?? this.xp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action_id': action_id,
      'user_id': user_id,
      'title': title,
      'image': image,
      'count': count,
      'xp': xp,
    };
  }

  static UserAction fromMap(Map<String, dynamic> map) {
    return UserAction(
      action_id: map['action_id'],
      user_id: map['user_id'],
      title: map['title'],
      image: map['image'],
      count: map['count'],
      xp: map['xp'],
    );
  }
// Merge method for combining UserActions
  static UserAction merge(UserAction a, UserAction b) {
    return UserAction(
      action_id: a.action_id,
      user_id: a.user_id,
      title: a.title,
      image: a.image,
      count: a.count + b.count,
      xp: a.xp + b.xp,
    );
  }

 // toString 메서드 추가
  @override
  String toString() {
    return 'UserAction(action_id: $action_id, user_id: $user_id, title: $title, image: $image, count: $count, xp: $xp)';
  }

}
