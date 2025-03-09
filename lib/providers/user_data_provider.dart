import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import '../database/database_service.dart';
import '../models/user.dart';
import '../models/user_action.dart';
import '../widgets/custom_badge.dart';
import '../models/daily_xp.dart';
import '../providers/badge_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDataProvider {
  final DatabaseService _databaseService = DatabaseService();
  final BadgeProvider _badgeProvider = BadgeProvider();
  final Uuid _uuid = Uuid();

  Future<User?> getUserById(String id) async {
    try {
      User? user = await _databaseService.getUserById(id);
      print('getUserById - Retrieved user: $user');
      return user;
    } catch (e) {
      print('Error retrieving user by ID: $e');
      return null;
    }
  }

  Future<User?> getUserByEmail(String email, String password) async {
    try {
      User? user = await _databaseService.getUser(email, password);
      print('getUserByEmail - Retrieved user: $user');
      return user;
    } catch (e) {
      print('Error retrieving user by email: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMyActionsList(String id) async {
    try {
      List<Map<String, dynamic>> actions = await _databaseService.getMyActionsList(id);
      print('getMyActionsList - Data retrieved for id $id: $actions');
      return actions;
    } catch (e) {
      print('Error retrieving actions list: $e');
      return [];
    }
  }

  Future<void> addMyActionslist(String id, Map<String, dynamic> action) async {
    try {
      await _databaseService.insertMyActionsList(id, action);
      print('addMyAction - Action added for id: $id');
    } catch (e) {
      print('Error adding action: $e');
      throw Exception("There is already the action in your list.");
    }
  }

  Future<void> updateMyActionsList(String id, List<Map<String, dynamic>> actions) async {
    try {
      await _databaseService.updateMyActionsList(id, actions);
      print('updateMyActionsList - Actions updated for id: $id');
    } catch (e) {
      print('Error updating actions list: $e');
    }
  }

  Future<String> saveUser({
    required String username,
    required String email,
    required String password,
    DateTime? creationDate,
    int xp = 0,
    int actionCount = 0,
    List<String> badges = const [],
    List<String> completedActions = const [],
  }) async {
    final user = User(
      id: _uuid.v4(),
      username: username,
      email: email,
      password: password,
      creationDate: (creationDate ?? DateTime.now()),
      xp: xp,
      actionCount: actionCount,
      badges: badges,
      completedActions: completedActions,
    );

    String newId = await _databaseService.insertUser(user);
    print('saveUser – User saved with ID: $newId');

    return newId;
  }

  Future<List<UserAction>> getActions(String id) async {
    try {
      List<UserAction> actions = await _databaseService.getActions(id);
      print('getActions - Data retrieved for id $id: $actions');
      return actions;
    } catch (e) {
      print('Error retrieving actions: $e');
      return [];
    }
  }

  Future<void> insertAction(UserAction action) async {
    try {
      final existingActions = await getActions(action.user_id);

      final existingAction = existingActions.firstWhereOrNull((element) => element.title == action.title);

      if (existingAction != null) {
        final updatedAction = existingAction.copyWith(
          count: existingAction.count + action.count,
          xp: existingAction.xp + action.xp,
        );
        await _databaseService.updateAction(updatedAction);
      } else {
        await _databaseService.insertAction(action);
      }
      print('insertAction - Action added or updated: $action');
    } catch (e) {
      print('Error inserting action: $e');
    }
  }

  Future<void> updateAction(UserAction action) async {
    try {
      await _databaseService.updateAction(action);
      print('updateAction - Action updated: $action');
    } catch (e) {
      print('Error updating action: $e');
    }
  }

  Future<List<CustomBadge>> getNewBadges(String id, int xp) async {
    User? user = await _databaseService.getUserById(id);
    List<String> earnedBadgeNames = user?.badges ?? [];

    List<CustomBadge> newBadges = _badgeProvider.getBadgesForXP(xp);
    List<CustomBadge> filteredNewBadges = newBadges.where((badge) => !earnedBadgeNames.contains(badge.name)).toList();

    print('Retrieved new badges for XP $xp: $filteredNewBadges');
    return filteredNewBadges;
  }

  Future<List<CustomBadge>> incrementXP({required String id, required int xp}) async {
    try {
      await _databaseService.incrementUserXP(id, xp);
      print('XP incremented for id: $id');

      User? updatedUser = await _databaseService.getUserById(id);
      if (updatedUser != null) {
        List<CustomBadge> newBadges = await getNewBadges(updatedUser.id, updatedUser.xp);
        print('New badges after incrementing XP: $newBadges');

        // Update user's badges
        List<String> updatedBadges = updatedUser.badges.toList();
        newBadges.forEach((badge) {
          if (!updatedBadges.contains(badge.name)) {
            updatedBadges.add(badge.name);
          }
        });

        // Save updated badges to user
        User updatedUserWithBadges = updatedUser.copyWith(badges: updatedBadges);
        await _databaseService.updateUser(updatedUserWithBadges);

        return newBadges;
      } else {
        print('Error fetching updated user after incrementing XP');
        return [];
      }
    } catch (e) {
      print('Error incrementing XP: $e');
      return [];
    }
  }

  Future<void> incrementUserActionTotalCount(String id) async {
    await _databaseService.incrementUserActionTotalCount(id);
  }



  Future<void> insertCompletedActions(UserAction action) async {
    try {
      await _databaseService.insertCompletedActions(action);
      print('insertCompletedAction - Completed action added: $action');
    } catch (e) {
      print('Error inserting completed action: $e');
    }
  }

  Future<void> updateCompletedActions(UserAction action) async {
    try {
      await _databaseService.updateCompletedActions(action);
      print('updateCompletedAction - Completed action updated: $action');
    } catch (e) {
      print('Error updating completed action: $e');
    }
  }

  Future<List<UserAction>> getCompletedActions(String userId) async {
    try {
      List<UserAction> completedActions = await _databaseService.getCompletedActions(userId);
      print('getCompletedActions - Completed actions retrieved for user: $userId');
      return completedActions;
    } catch (e) {
      print('Error retrieving completed actions: $e');
      return [];
    }
  }

  Future<List<CustomBadge>> handleActionButtonPressed({
    required String id,
    required String title,
    required String image,
    required int xp,
  }) async {
    List<CustomBadge> newBadges = [];
    try {
      List<UserAction> userActions = await getActions(id);
      UserAction? existingAction = userActions.firstWhereOrNull((a) => a.title == title);

      List<UserAction> completedActions = await getCompletedActions(id);
      UserAction? existingCompletedAction = completedActions.firstWhereOrNull((a) => a.title == title);

      UserAction updatedAction;
      int newActionId = userActions.isNotEmpty ? userActions.map((a) => a.action_id).reduce((a, b) => a > b ? a : b) + 1 : 1;

      if (existingAction == null) {
        updatedAction = UserAction(
          action_id: newActionId,
          user_id: id,
          title: title,
          image: image,
          xp: xp,
          count: 1,
        );
        await insertAction(updatedAction);
      } else {
        updatedAction = existingAction.copyWith(
          xp: existingAction.xp + xp,
          count: existingAction.count + 1,
        );
        await updateAction(updatedAction);
      }

      // 사용자 XP 증가 로직
      newBadges = await _incrementUserXP(id, xp);

      await incrementUserActionTotalCount(id);
      String today = DateTime.now().toIso8601String().split('T').first;
      await _databaseService.updateDailyXPForDate(id: id, date: today, xp: xp);  // 변경된 부분

      if (existingCompletedAction == null) {
        await insertCompletedActions(updatedAction);
      } else {
        final updatedCompletedAction = existingCompletedAction.copyWith(
          xp: existingCompletedAction.xp + xp,
          count: existingCompletedAction.count + 1,
        );
        await updateCompletedActions(updatedCompletedAction);
      }
    } catch (e) {
      print("Error handling action button press: $e");
    }
    return newBadges;
  }

  // 사용자 XP 증가 로직을 별도의 함수로 분리
  Future<List<CustomBadge>> _incrementUserXP(String id, int xp) async {
    try {
      print('Incrementing XP for user $id by $xp');
      List<CustomBadge> newBadges = await incrementXP(id: id, xp: xp);
      if (newBadges.isNotEmpty) {
        return newBadges;
      } else {
        print('No new badges earned.');
        return [];
      }
    } catch (e) {
      print('Error incrementing user XP: $e');
      return [];
    }
  }

  void _showEarnedBadges(List<CustomBadge> badges) {
    for (var badge in badges) {
      print('Badge earned: ${badge.name}');
      // Show dialog or notification to user
    }
  }

  Future<Database> get database async {
    return _databaseService.database;
  }


  // 로그아웃 메서드 추가
  Future<void> logout() async {
    try {
      // 사용자 세션이나 토큰 삭제 처리
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // 모든 저장된 세션이나 토큰 삭제

      print('User logged out');
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  // 계정 삭제 메서드 추가
  Future<void> deleteUser(String userId) async {
    try {
      await _databaseService.deleteUser(userId);
      print('User with ID $userId deleted');
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}

