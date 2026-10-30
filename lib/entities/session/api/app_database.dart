import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

Future<Database> openAppDatabase() async {
  final dir = await getDatabasesPath();
  final path = p.join(dir, 'soonmodoro.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      db.execute(
        'create table sessions(id integer primary key auto_increment, mode text not null, started_at integer not null, ended_at integer not null)',
      );
      db.execute(
        'create index idx_sessions_started_at on session(started_at);',
      );
    },
  );
}
