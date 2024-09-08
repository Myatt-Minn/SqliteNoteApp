import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class SqlHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute(
        """CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, description TEXT, createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)""");
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'sqliteNoteApp',
      version: 1,
      onCreate: (sql.Database db, int version) async {
        await createTable(db);
      },
    );
  }

  static Future<int> createItem(String title, String? description) async {
    final database = await db();
    final item = {'title': title, 'description': description};
    final id = await database.insert(
      'items',
      item,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final database = await db();
    return database.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final database = await db();
    return database.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String title, String? description) async {
    final database = await db();
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };
    return await database
        .update("items", data, where: "id = ?", whereArgs: [id]);
  }

  static Future<void> deleteItem(int id) async {
    final database = await db();
    try {
      await database.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (e) {
      debugPrint("Something went wrong sir!");
    }
  }
}
