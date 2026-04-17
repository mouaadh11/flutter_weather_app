// services/city_repository.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CityRepository {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await openDatabase(
      join(await getDatabasesPath(), 'cities.db'),
      onCreate: (db, _) => db.execute(
        'CREATE TABLE cities(id INTEGER PRIMARY KEY, name TEXT UNIQUE)',
      ),
      version: 1,
    );
    return _db!;
  }

  Future<List<String>> getSavedCities() async {
    final rows = await (await db).query('cities', orderBy: 'id ASC');
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<void> addCity(String name) async =>
      (await db).insert('cities', {'name': name},
          conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<void> removeCity(String name) async =>
      (await db).delete('cities', where: 'name = ?', whereArgs: [name]);
}