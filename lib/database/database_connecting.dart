import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseConnection {
  setDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var path = join(directory.path, 'sqflite_db2');
    var database = await openDatabase(
      path,
      version: 7,
      onCreate: (db, version) {
        _onCreatingDatabase(db, version);
      },
    );
    return database;
  }
}

_onCreatingDatabase(Database database, int version) async {
  await database.execute('''
CREATE TABLE roomHotel (
    id     INTEGER PRIMARY KEY AUTOINCREMENT,
    name   TEXT,
    status TEXT,
    image  TEXT,
    loaiphong TEXT
);''');

  await database.execute('''CREATE TABLE customertable (
    id       INTEGER PRIMARY KEY AUTOINCREMENT,
    name     TEXT,
    sdt      TEXT,
    cccd     TEXT,
    ngayvao  TEXT,
    ngayra   TEXT,
    id_phong INTEGER REFERENCES roomHotel (id) 
);''');

  await database.execute('''
CREATE TABLE history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT,
    sdt TEXT,
    cccd TEXT,
    ngayvao TEXT,
    ngayra TEXT,
    id_phong INTEGER,
    loaiphong TEXT,
    gia INTEGER,
    thoi_gian_thue TEXT,
    thanh_toan INTEGER
);
''');

  await database.execute('''
      CREATE TABLE room_pricing (
        loaiphong TEXT PRIMARY KEY,
        gia INTEGER
      );
    ''');

  await database.execute('''
      CREATE TABLE payment_qr (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        qr_image TEXT
      );
    ''');

  // Chèn dữ liệu mặc định cho bảng room_pricing
  await database.insert('room_pricing', {'loaiphong': 'Thường', 'gia': 50000});
  await database.insert('room_pricing', {'loaiphong': 'Vip', 'gia': 80000});
  await database.insert('room_pricing', {
    'loaiphong': 'Đặc biệt',
    'gia': 120000,
  });

  // Chèn bản ghi mặc định cho payment_qr (ban đầu để trống)
  await database.insert('payment_qr', {'qr_image': ''});
}
