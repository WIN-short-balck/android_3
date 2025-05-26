import 'package:giadienver1/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/list_thong_bao.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<bool> verifyOTP(String email, String otp) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final result = await db.query(
      'otp_verifications',
      where: 'email = ? AND otp = ? AND expires_at > ?',
      whereArgs: [email, otp, now],
    );
    return result.isNotEmpty;
  }

  Future<void> xacminhEmail(String email) async {
    final db = await database;
    await db.update(
      'users',
      {'is_verified': 1},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<int> resetPassword(String email, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  Future<void> saveOTP(String email, String otp) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final hetHan = now + 300; // Thời gian hết hạn là 5 phút
    await db.insert('otp_verifications', {
      'email': email,
      'otp': otp,
      'created_at': now,
      'expires_at': hetHan,
    });
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('thongbao4.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE thongbao (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        noiDung TEXT NOT NULL,
        nguoiDang TEXT
      )
    ''');

        await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT,
        avatar_path TEXT,
        is_verified INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE otp_verifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        otp TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await db.insert('thongbao', {
      'title': 'Thông báo: thưởng tăng lương!!',
      'noiDung': 'Tất cả sẽ được tăng lương x3',
      'nguoiDang': 'Cao Quang Khánh',
    });
    await db.insert('thongbao', {
      'title': 'Thông báo: nghỉ lễ',
      'noiDung':
          'Tất cả nhân viên sẽ được nghỉ lễ từ ngày 30/4 đến hết ngày 1/5, ngày 2/5 đi làm lại như bình thường',
      'nguoiDang': 'Phạm Thắng',
    });
  }

  Future<List<ThongBao>> getAllThongBao() async {
    final db = await database;
    final result = await db.query('thongbao', orderBy: 'id DESC');
    return result.map((json) => ThongBao.fromMap(json)).toList();
  }

  Future<int> insertThongBao(ThongBao thongBao) async {
    final db = await database;
    return await db.insert('thongbao', thongBao.toMap());
  }

  Future<int> updateThongBao(ThongBao thongBao) async {
    final db = await database;
    return await db.update(
      'thongbao',
      thongBao.toMap(),
      where: 'id = ?',
      whereArgs: [thongBao.id],
    );
  }

  Future<int> deleteThongBao(int id) async {
    final db = await database;
    return await db.delete('thongbao', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> debugThongBaoCount() async {
    final db = await database;
    final result = await db.query('thongbao');
    print('Số lượng thông báo trong DB: ${result.length}');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // --------------------- USERS ---------------------
  // Đăng ký người dùng
  Future<int> insertUser(String email, String password) async {
    final db = await database;
    return await db.insert('users', {'email': email, 'password': password});
  }

  Future<bool> isEmailExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  // Kiểm tra đăng nhập
  Future<bool> checkLogin(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty;
  }

  // Đổi mật khẩu (có kiểm tra mật khẩu cũ)
  Future<int> updatePassword(
    String email,
    String oldPassword,
    String newPassword,
  ) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ? AND password = ?',
      whereArgs: [email, oldPassword],
    );
  }

  // Lấy tên theo email
  Future<String?> getUserName(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first['name'] as String?;
    }
    return null;
  }

  // Lấy user theo email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      final row = result.first;
      return User(
        email: row['email'] as String,
        password: row['password'] as String,
        name: row['name'] as String?,
        avatarPath: row['avatar_path'] as String?,
      );
    }
    return null;
  }

    Future<int> updateUser(String email, String name, String? avatarPath) async {
    final db = await database;
    final data = {'name': name};
    if (avatarPath != null) {
      data['avatar_path'] = avatarPath;
    }
    return await db.update(
      'users',
      data,
      where: 'email = ?',
      whereArgs: [email],
    );
  }
  
}
