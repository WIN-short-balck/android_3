import 'package:giadienver1/database/database_connecting.dart';
import 'package:sqflite/sqflite.dart';

class Repository {
  late DatabaseConnection _databaseConnection;

  Repository() {
    _databaseConnection = DatabaseConnection();
  }

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _databaseConnection.setDatabase();

    if (_database == null) {
      throw Exception("Database not initialized properly!");
    }

    return _database!;
  }


  // Thêm dữ liệu vào bảng
  Future<int> insertData(String table, Map<String, dynamic> data) async {
    var connection = await database;
    return await connection.insert(table, data);
  }

  //Đcọ dữ liệu từ bảng thiết lập thanh toán
  Future<List<Map<String,dynamic>>> readPrice(String table) async{
    var connection = await database;
    return await connection.query(table);
  }

  // Đọc dữ liệu từ bảng
  Future<List<Map<String, dynamic>>> readData(String table) async {
    var connection = await database;
    return await connection.query(table);
  }

  // Thêm khách hàng
  Future<int> insertCustomer(String table, Map<String, dynamic> data) async {
    var connection = await database;
    return await connection.insert(table, data);
  }

  // Đọc thông tin khách hàng
  Future<List<Map<String, dynamic>>> readCustomer(String table) async {
    var connection = await database;
    return await connection.query(table);
  }

  // Lấy thông tin khách hàng theo id_phong
  Future<List<Map<String, dynamic>>> thongtinkhachhang(int idPhong) async {
    var connection = await database;
    return await connection.query(
      'customertable',
      where: 'id_phong = ?',
      whereArgs: [idPhong],
    );
  }

  // Xóa thông tin khách hàng khi thanh toán
  Future<void> xoaCustomer(int id) async {
    var connection = await database;
    await connection.delete('customertable', where: 'id = ?', whereArgs: [id]);
  }

  // Cập nhật dữ liệu (đổi tên từ updateCustomer thành updateData cho nhất quán)
  Future<int> updateData(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    var connection = await database;
    return await connection.update(table, data, where: where, whereArgs: whereArgs);
  }

  // Lấy danh sách liên lạc
    Future<List<Map<String, dynamic>>> layDanhSachLienLac() async {
    var connection = await database;
    return await connection.query(
      'customertable',
      columns: ['id', 'id_phong', 'name', 'cccd', 'sdt', 'ngayvao', 'ngayra'],
    );
  }


  // Xóa dữ liệu từ bảng với điều kiện
  Future<int> deleteData(String table, String where, List<dynamic> whereArgs) async {
    var connection = await database;
    return await connection.delete(table, where: where, whereArgs: whereArgs);
  }

  // Kiểm tra xem bản ghi có tồn tại không
  Future<bool> checkExists(String table, String where, List<dynamic> whereArgs) async {
    var connection = await database;
    var result = await connection.query(
      table,
      where: where,
      whereArgs: whereArgs,
    );
    return result.isNotEmpty;
  }

  // Xóa toàn bộ dữ liệu trong bảng
  Future<void> deleteAllData(String table) async {
    var connection = await database;
    await connection.delete(table);
  }
  // History
  Future<List<Map<String, dynamic>>> readHistory() async {
    var connection = await database;
    return await connection.query('history');
  }

  Future<int> insertHistory(Map<String, dynamic> data) async {
    var connection = await database;
    return await connection.insert('history', data);
  }

  Future<int> deleteHistoryById(int id) async {
    return await _database!.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllHistory() async {
    return await _database!.delete('history');
  }

  Future<List<Map<String, dynamic>>> layDanhSachPhong() async {
    var connection = await database;
    return await connection.query(
      'roomHotel',
      columns: ['id', 'name', 'status', 'image', 'loaiphong'],
    );
  }

  //xoa phong 
  
}