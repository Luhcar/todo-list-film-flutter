import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'movie.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('film.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE films (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT NOT NULL,
        deskripsi TEXT NOT NULL,
        selesaiDitonton INTEGER NOT NULL
      )
    ''');
  }

  Future<void> createFilm(Film film) async {
    final db = await instance.database;
    await db.insert('films', film.toMap());
  }

  Future<List<Film>> readFilms() async {
    final db = await instance.database;
    final result = await db.query('films');
    return result.map((map) => Film.fromMap(map)).toList();
  }

  Future<void> updateFilm(Film film) async {
    final db = await instance.database;
    await db.update('films', film.toMap(), where: 'id = ?', whereArgs: [film.id]);
  }

  Future<void> deleteFilm(int id) async {
    final db = await instance.database;
    await db.delete('films', where: 'id = ?', whereArgs: [id]);
  }
}
