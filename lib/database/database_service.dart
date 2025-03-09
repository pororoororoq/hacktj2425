import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/user_action.dart';
import '../models/daily_xp.dart';
import '../utils/date_utils.dart' as custom_date_utils; // 추가

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }



  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'user_database.db');
    print('Database path: $path');
    return openDatabase(
      path,
      version: 7, // 버전을 7로 증가
      onCreate: (db, version) async {
        await _createTables(db);
        print('Database created with version: $version');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 7) {
          await _upgradeDatabase(db);
          print('Database upgraded from version $oldVersion to $newVersion');
        }
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS users('
      'id TEXT PRIMARY KEY, '
      'username TEXT, '
      'email TEXT, '
      'password TEXT, '
      'creationDate TEXT, '
      'xp INTEGER, '
      'actionCount INTEGER, '
      'badges TEXT, '
      'completedActions TEXT'
      ')',
    );
    print('Users table created');

    await db.execute(
      'CREATE TABLE IF NOT EXISTS user_actions('
      'action_id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'user_id TEXT, '
      'title TEXT, '
      'image TEXT, '
      'xp INTEGER, '
      'count INTEGER'
      ')',
    );
    print('User actions table created');

    await db.execute(
      'CREATE TABLE IF NOT EXISTS daily_xp('
      'daily_xp_id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'user_id TEXT, '
      'date TEXT, '
      'xp INTEGER'
      ')',
    );
    print('Daily XP table created');

    await db.execute(
      'CREATE TABLE IF NOT EXISTS myActionsList('
      'list_id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'user_id TEXT, '
      'image TEXT, '
      'itemName TEXT, '
      'disposalCategory TEXT, '
      'title TEXT'
      ')',
    );
    print('My Actions List table created');

    await db.execute(
      'CREATE TABLE IF NOT EXISTS completed_actions('
      'action_id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'user_id TEXT, '
      'title TEXT, '
      'image TEXT, '
      'xp INTEGER, '
      'count INTEGER'
      ')',
    );
    print('Completed Actions table created');
  }

Future<void> _upgradeDatabase(Database db) async {
  final tables = await db.rawQuery('SELECT name FROM sqlite_master WHERE type="table"');

  // completed_actions 테이블 존재 여부 확인 및 생성
  if (!tables.any((table) => table['name'] == 'completed_actions')) {
    await db.execute(
      'CREATE TABLE completed_actions('
      'action_id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'user_id TEXT, '
      'title TEXT, '
      'image TEXT, '
      'xp INTEGER, '
      'count INTEGER'
      ')',
    );
  } else {
    final completedActionsTableInfo = await db.rawQuery('PRAGMA table_info(completed_actions)');
    final hasActionIdColumn = completedActionsTableInfo.any((column) => column['name'] == 'action_id');

    if (!hasActionIdColumn) {
      await db.execute('ALTER TABLE completed_actions ADD COLUMN action_id INTEGER PRIMARY KEY AUTOINCREMENT');
    }
  }

  // user_actions 테이블 업데이트
  final tableInfo = await db.rawQuery('PRAGMA table_info(user_actions)');
  final hasXpColumn = tableInfo.any((column) => column['name'] == 'xp');
  final hasCountColumn = tableInfo.any((column) => column['name'] == 'count');

  if (!hasXpColumn) {
    await db.execute('ALTER TABLE user_actions ADD COLUMN xp INTEGER');
  }

  if (!hasCountColumn) {
    await db.execute('ALTER TABLE user_actions ADD COLUMN count INTEGER');
  }

  // daily_xp 테이블 업데이트
  final dailyXpTableInfo = await db.rawQuery('PRAGMA table_info(daily_xp)');
  final hasUserIdColumn = dailyXpTableInfo.any((column) => column['name'] == 'user_id');

  if (!hasUserIdColumn) {
    await db.execute('ALTER TABLE daily_xp ADD COLUMN user_id TEXT');
  }

  // myActionsList 테이블 재생성
  await db.execute('DROP TABLE IF EXISTS myActionsList');
  await db.execute(
    '''CREATE TABLE myActionsList(
        list_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        image TEXT,
        itemName TEXT,
        disposalCategory TEXT,
        title TEXT
      )''',
  );
}


  Future<void> dropAllTables() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS users');
    await db.execute('DROP TABLE IF EXISTS user_actions');
    await db.execute('DROP TABLE IF EXISTS daily_xp');
    await db.execute('DROP TABLE IF EXISTS myActionsList');
    await db.execute('DROP TABLE IF EXISTS completed_actions');
    print('All tables dropped');
    await _createTables(db);
  }

  Future<String> insertUser(User user) async {
    try {
      final db = await database;
      print('Inserting user: ${user.toMap()}');
      await db.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('insertUser - User inserted with ID: ${user.id}');
      return user.id;
    } catch (e) {
      print("Error inserting user: $e");
      return '';
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
    } catch (e) {
      print("Error getting user by id: $e");
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
    } catch (e) {
      print("Error getting user by email: $e");
    }
    return null;
  }

  Future<User?> getUser(String email, String password) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
    } catch (e) {
      print("Error getting user: $e");
    }
    return null;
  }

  Future<void> updateUser(User user) async {
    try {
      final db = await database;
      await db.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      print("Error updating user: $e");
    }
  }


  Future<void> incrementDailyXP(String userId, int xp, String date) async {
  final db = await database;

  // Mock Date 적용
  DateTime now = custom_date_utils.DateUtils.getToday();
  String date = custom_date_utils.DateUtils.formatDate(now);

  final List<Map<String, dynamic>> maps = await db.query(
    'daily_xp',
    where: 'user_id = ? AND date = ?',
    whereArgs: [userId, date],
  );

  if (maps.isNotEmpty) {
    final currentXP = maps.first['xp'] as int;
    final newXP = currentXP + xp;
    await db.update(
      'daily_xp',
      {
        'xp': newXP,
      },
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
    );
  print('Updated daily XP for $date: $newXP');
  } else {
    await db.insert(
      'daily_xp',
      {
        'user_id': userId,
        'date': date,
        'xp': xp,
      },
    );
    print('Inserted new daily XP for $date: $xp');
  }
}

  Future<void> incrementUserXP(String id, int xp) async {
    try {
      final db = await database;
      int updated = await db.rawUpdate('''
        UPDATE users
        SET xp = xp + ?
        WHERE id = ?
      ''', [xp, id]);
      if (updated == 1) {
        print("User XP incremented successfully for id: $id");
      } else {
        print("User XP increment failed for id: $id");
      }
    } catch (e) {
      print("Error incrementing user XP: $e");
    }
  }


Future<List<DailyXP>> getDailyXP(String id) async {
  try {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_xp',
      where: 'user_id = ?',
      whereArgs: [id],
    );

    return List.generate(maps.length, (i) {
      return DailyXP.fromMap(maps[i]);
    });
  } catch (e) {
    print("Error getting daily XP: $e");
    return [];
  }
}

Future<void> updateDailyXPForDate({
  required String id,
  required String date,
  required int xp,
}) async {
  try {
    await incrementDailyXP(id, xp, date);
  } catch (e) {
    print("Error updating daily XP: $e");
  }
}



  Future<void> checkAndResetDailyXP(String userId) async {
  final db = await database;
  String today = custom_date_utils.DateUtils.formatDate(DateTime.now());

  final List<Map<String, dynamic>> maps = await db.query(
    'daily_xp',
    where: 'user_id = ? AND date = ?',
    whereArgs: [userId, today],
  );

  if (maps.isEmpty) {
    await db.insert(
      'daily_xp',
      {
        'user_id': userId,
        'date': today,
        'xp': 0,
      },
    );
    print("Daily XP reset for new day: $today for user: $userId");
  }
}



  Future<List<UserAction>> getActions(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'user_actions',
        where: 'user_id = ?',
        whereArgs: [id],
      );
      return List.generate(maps.length, (i) {
        return UserAction.fromMap(maps[i]);
      });
    } catch (e) {
      print("Error getting actions: $e");
      return [];
    }
  }

  Future<void> updateAction(UserAction action) async {
    try {
      final db = await database;
      await db.update(
        'user_actions',
        action.toMap(),
        where: 'action_id = ?',
        whereArgs: [action.action_id],
      );
    } catch (e) {
      print("Error updating action: $e");
    }
  }

  Future<void> insertAction(UserAction action) async {
    try {
      final db = await database;
      await db.insert(
        'user_actions',
        action.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting action: $e");
    }
  }

  Future<void> incrementUserActionCount(String id, String title) async {
    try {
      final db = await database;
      await db.rawUpdate('''
        UPDATE user_actions
        SET count = count + 1
        WHERE title = ? AND user_id = ?
      ''', [title, id]);
    } catch (e) {
      print("Error incrementing action count: $e");
    }
  }

  Future<void> incrementUserActionXP(String id, String title, int xp) async {
    try {
      final db = await database;
      await db.rawUpdate('''
        UPDATE user_actions
        SET xp = xp + ?
        WHERE title = ? AND user_id = ?
      ''', [xp, title, id]);
    } catch (e) {
      print("Error incrementing action XP: $e");
    }
  }

  Future<int> getUserActionCount(String id, String title) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'user_actions',
        columns: ['count'],
        where: 'user_id = ? AND title = ?',
        whereArgs: [id, title],
      );
      if (maps.isNotEmpty) {
        return maps.first['count'] ?? 0;
      }
    } catch (e) {
      print("Error getting action count: $e");
    }
    return 0;
  }

  Future<int> getUserActionXP(String id, String title) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'user_actions',
        columns: ['xp'],
        where: 'user_id = ? AND title = ?',
        whereArgs: [id, title],
      );
      if (maps.isNotEmpty) {
        return maps.first['xp'] ?? 0;
      }
    } catch (e) {
      print("Error getting action XP: $e");
    }
    return 0;
  }

  Future<void> incrementUserActionTotalCount(String id) async {
    try {
      final db = await database;
      int updated = await db.rawUpdate('''
        UPDATE users
        SET actionCount = actionCount + 1
        WHERE id = ?
      ''', [id]);
      if (updated == 1) {
        print("User action count incremented successfully for id: $id");
      } else {
        print("User action count increment failed for id: $id");
      }
    } catch (e) {
      print("Error incrementing user action total count: $e");
    }
  }

  Future<void> addUserActionList(List<UserAction> actions) async {
    try {
      final db = await database;
      final batch = db.batch();
      for (var action in actions) {
        batch.insert(
          'user_actions',
          action.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e) {
      print("Error adding user action list: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getMyActionsList(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'myActionsList',
        where: 'user_id = ?',
        whereArgs: [id],
      );

      print('getMyActionsList - Data retrieved for id $id: $maps');

      return maps;
    } catch (e) {
      print("Error getting my actions list: $e");
      return [];
    }
  }

  Future<void> insertMyActionsList(String id, Map<String, dynamic> action) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> existingActions = await db.query(
        'myActionsList',
        where: 'user_id = ? AND title = ?',
        whereArgs: [id, action['title']],
      );

      if (existingActions.isNotEmpty) {
        await db.update(
          'myActionsList',
          action,
          where: 'user_id = ? AND title = ?',
          whereArgs: [id, action['title']],
        );
      } else {
        await db.insert(
          'myActionsList',
          action,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      print('addMyAction - Action added for id: $id');
    } catch (e) {
      print("Error inserting my action: $e");
      throw Exception("This action already exists in your list.");
    }
  }

  Future<void> updateMyActionsList(String id, List<Map<String, dynamic>> actions) async {
    try {
      final db = await database;

      for (Map<String, dynamic> action in actions) {
        final List<Map<String, dynamic>> existingActions = await db.query(
          'myActionsList',
          where: 'user_id = ? AND title = ?',
          whereArgs: [id, action['title']],
        );

        if (existingActions.isNotEmpty) {
          await db.update(
            'myActionsList',
            action,
            where: 'user_id = ? AND title = ?',
            whereArgs: [id, action['title']],
          );
        } else {
          await db.insert(
            'myActionsList',
            action,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      print('updateMyActionsList - Actions updated for id: $id');
    } catch (e) {
      print("Error updating my actions list: $e");
    }
  }

  Future<bool> checkIfActionExists(String userId, String title) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'myActionsList',
      where: 'user_id = ? AND title = ?',
      whereArgs: [userId, title],
    );
    return result.isNotEmpty;
  }

  Future<List<UserAction>> getCompletedActions(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'completed_actions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) {
      return UserAction.fromMap(maps[i]);
    });
  }

  Future<void> insertCompletedActions(UserAction action) async {
    final db = await database;
    await db.insert(
      'completed_actions',
      action.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCompletedActions(UserAction action) async {
    final db = await database;
    await db.update(
      'completed_actions',
      action.toMap(),
      where: 'action_id = ?',
      whereArgs: [action.action_id],
    );
  }

Future<void> deleteUser(String userId) async {
  final db = await database;

  await db.transaction((txn) async {
    try {
      await txn.delete(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      print('User with ID $userId deleted from the users table.');

      await txn.delete(
        'user_actions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      print('User with ID $userId deleted from the user_actions table.');

      await txn.delete(
        'daily_xp',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      print('User with ID $userId deleted from the daily_xp table.');

      await txn.delete(
        'myActionsList',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      print('User with ID $userId deleted from the myActionsList table.');

      await txn.delete(
        'completed_actions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      print('User with ID $userId deleted from the completed_actions table.');
    } catch (e) {
      print('Error deleting user with ID $userId: $e');
      throw Exception('Failed to delete user.');
    }
  });
}


  Future<void> printDatabaseContents() async {
    final db = await database;

    final users = await db.query('users');
    print('Users:');
    for (var user in users) {
      print(user);
    }

    final userActions = await db.query('user_actions');
    print('User Actions:');
    for (var action in userActions) {
      print(action);
    }

    final dailyXP = await db.query('daily_xp');
    print('Daily XP:');
    for (var xp in dailyXP) {
      print(xp);
    }

    final myActionsList = await db.query('myActionsList');
    print('My Actions List:');
    for (var action in myActionsList) {
      print(action);
    }

    final completedActions = await db.query('completed_actions');
    print('Completed Actions:');
    for (var action in completedActions) {
      print(action);
    }
  }
}


  