import 'package:sqflite/sqflite.dart';

class SessionDao {
  final Database _db;

  SessionDao({required this._db});

  Future<int> insert(Map<String, Object?> row) => _db.insert('session', row);

  Future<List<Map<String, Object?>>> queryByDateRange(int from, int to) =>
      _db.query(
        'session',
        where: 'started_at >= ? and started_at < ?',
        whereArgs: [from, to],
      );

  Future<List<Map<String, Object?>>> queryAll() =>
      _db.query('select * from sessions');
}
