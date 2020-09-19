import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final _databaseName = "wanderer.db";
  static final _databaseVersion = 1;

  static final table = 'location';

  static final columnId = '_id';
  static final columnName = 'name';
  static final columnAddress = 'address';
  static final columnLat = 'lat';
  static final columnLng = 'lng';
  static final columnImgPath = 'img_path';
  static final columnDateStamp = 'date_stamp';
  static final columnUserID = 'user_id';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    String sql = "CREATE TABLE $table (" +
        "$columnId INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "$columnName TEXT NOT NULL, " +
        "$columnAddress TEXT NOT NULL, " +
        "$columnLat TEXT NOT NULL, " +
        "$columnLng TEXT NOT NULL, " +
        "$columnImgPath TEXT NOT NULL, " +
        "$columnDateStamp TEXT NOT NULL, " +
        "$columnUserID TEXT NOT NULL " +
        ")";
    await db.execute(sql);
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<void> backupDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    Directory targetDirectory = await getExternalStorageDirectory();

    String pathSource = join(documentsDirectory.path, _databaseName);
    String pathTarget = join(targetDirectory.path, _databaseName);
    String pathTarget1 = join(targetDirectory.path, 'anjing.txt');
    final fileSource = File('$pathSource');
    var fileTarget = File('$pathTarget');
    var fileTarget1 = File('$pathTarget1');
    print('$pathSource---$pathTarget---$fileSource---$fileTarget');
    try {
      //final file = await _localFile;

      // Read the file
      Uint8List contents = await fileSource.readAsBytes();// .readAsString();
      print('$contents');
      await fileTarget1.writeAsString('$contents');
      await fileTarget.writeAsBytes(contents);
      //return contents; //int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }
}
