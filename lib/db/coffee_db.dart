import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'coffee_record.dart';

class CoffeeDB {
  static final CoffeeDB _instance = CoffeeDB._internal();
  factory CoffeeDB() => _instance;
  CoffeeDB._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'coffee_records.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('DROP TABLE IF EXISTS coffee_records');
        await db.execute('''
          CREATE TABLE coffee_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            brand TEXT,
            type TEXT,
            size TEXT,
            volume INTEGER,
            caffeine INTEGER,
            createdAt TEXT,
            price INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS coffee_records');
        await db.execute('''
          CREATE TABLE coffee_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            brand TEXT,
            type TEXT,
            size TEXT,
            volume INTEGER,
            caffeine INTEGER,
            createdAt TEXT,
            price INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertRecord(CoffeeRecord record) async {
    final db = await database;
    return await db.insert('coffee_records', record.toMap());
  }

  Future<List<CoffeeRecord>> getRecordsByMonth(int year, int month) async {
    final db = await database;
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final maps = await db.query(
      'coffee_records',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt ASC',
    );
    return maps.map((e) => CoffeeRecord.fromMap(e)).toList();
  }

  // 可扩展：查询、删除、统计等方法
} 