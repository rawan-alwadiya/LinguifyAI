import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:LinguifyAI/models/chat_message_model.dart';
import 'package:sqflite/sqflite.dart';


// class ChatDatabaseOperations {
//   static final ChatDatabaseOperations _instance = ChatDatabaseOperations._internal();
//   static Database? _database;
//
//
//   factory ChatDatabaseOperations() {
//     return _instance;
//   }
//
//   ChatDatabaseOperations._internal();
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'chatbot.db');
//     return await openDatabase(
//       path,
//       onCreate: (db, version) {
//         return db.execute(
//           'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT, isUser INTEGER)',
//         );
//       },
//       version: 1,
//     );
//   }
//
//   Future<void> saveMessage(String message, bool isUser) async {
//     final db = await database;
//     await db.insert('messages', {
//       'message': message,
//       'isUser': isUser ? 1 : 0,
//     });
//   }
//
//   Future<List<ChatMessage>> getMessages() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('messages');
//
//     return List.generate(maps.length, (i) {
//       return ChatMessage(
//         id: maps[i]['id'],
//         message: maps[i]['message'],
//         isUser: maps[i]['isUser'] == 1,
//       );
//     });
//   }
// }

class ChatDatabaseOperations {
  // static final ChatDatabaseOperations _instance = ChatDatabaseOperations._internal();
  // static Database? _database;

  late Database _database;
  static ChatDatabaseOperations? _instance;

  ChatDatabaseOperations._internal();

  factory ChatDatabaseOperations() {
    return _instance ??= ChatDatabaseOperations._internal();
  }

  Database get database => _database;


  // Future<Database> get database async {
  //   if (_database != null) return _database!;
  //
  //   _database = await _initDatabase();
  //   return _database!;
  // }

  // Future<Database> _initDatabase() async {
  //   String path = join(await getDatabasesPath(), 'chatbot.db');
  //   return await openDatabase(
  //     path,
  //     onCreate: (db, version) {
  //       return db.execute(
  //         'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT, isUser INTEGER)',
  //       );
  //     },
  //     version: 1,
  //   );
  // }

  Future<void> initDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'chatbot.db');
    _database = await openDatabase(
        path,
        version: 1,
        onOpen: (Database database){},
        onCreate: (Database database, int version) async {
          await database.execute(
          'CREATE TABLE messages(id INTEGER PRIMARY KEY AUTOINCREMENT, message TEXT, isUser INTEGER)',
          );
        },
    onUpgrade: (Database database, int oldVersion, newVersion){},
    onDowngrade: (Database database, int oldVersion, newVersion){}
    );
  }


  int maxMessageCount = 100;
  Future<void> saveMessage(String message, bool isUser) async {
    final db = database;

    // Count current messages
    int messageCount = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM messages'),
    ) ?? 0;

    // Delete the oldest message if limit is reached
    if (messageCount >= maxMessageCount) {
    await db.delete(
    'messages',
    where: 'id = (SELECT id FROM messages ORDER BY id ASC LIMIT 1)',
    );
    }

    // Save the new message
    await db.insert('messages', {
      'message': message,
      'isUser': isUser ? 1 : 0,
    });
  }

  Future<void> deleteLastMessage() async {
    final db = database;
    await db.delete(
      'messages',
      where: 'id = (SELECT id FROM messages ORDER BY id DESC LIMIT 1)',
    );
  }

  Future<void> deleteChatHistory() async {
    final db = database;
    await db.delete('messages');
  }

  Future<List<ChatMessage>> getMessages() async {
    final db = database;
    final List<Map<String, dynamic>> maps = await db.query('messages');

    return List.generate(maps.length, (i) {
      return ChatMessage(
        id: maps[i]['id'],
        message: maps[i]['message'],
        isUser: maps[i]['isUser'] == 1,
      );
    });
  }
}

