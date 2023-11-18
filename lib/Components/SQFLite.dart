//
//
// import 'package:sqflite/sqflite.dart';
// import 'package:intl/intl.dart';
//
// Future<Database> get database async {
//   if (database != null) return database!;
//
//   var _database = await _initDB('notes.db');
//   return _database!;
// }
//
// Future<Database> _initDB(String filePath) async {
//   final dbPath = await getDatabasesPath();
//   final path = join(dbPath, filePath);
//
//   return await openDatabase(path, version: 1, onCreate: _createDB);
// }
//
// Future _createDB(Database db, int version) async {
//   final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
//   final textType = 'TEXT NOT NULL';
//   final boolType = 'BOOLEAN NOT NULL';
//   final integerType = 'INTEGER NOT NULL';
//
//   await db.execute('''
// CREATE TABLE $tableNotes (
//   ${NoteFields.id} $idType,
//   ${NoteFields.isImportant} $boolType,
//   ${NoteFields.number} $integerType,
//   ${NoteFields.title} $textType,
//   ${NoteFields.description} $textType,
//   ${NoteFields.time} $textType
//   )
// ''');
// }
//
// class Note {
//   final int? id;
//   final bool isImportant;
//   final int number;
//   final String title;
//   final String description;
//   final DateTime createdTime;
//
//   const Note({
//     this.id,
//     required this.isImportant,
//     required this.number,
//     required this.title,
//     required this.description,
//     required this.createdTime,
//   });