import 'package:flutter/foundation.dart';
import 'package:giadienver1/database/database_connecting.dart';
import 'package:giadienver1/database/repository.dart';
import 'package:giadienver1/models/customer.dart';
import 'package:giadienver1/models/room.dart';

class RoomServices {
  final Repository _room = Repository();

  Future<Map<String, dynamic>?> getRoomById(int id) async {
  var rooms = await _room.readData('roomHotel');
  for (var room in rooms) {
    if (room['id'] == id) {
      return room;
    }
  }
  return null;
}



  // Lấy giá theo loại phòng từ room_pricing
  Future<int> getPriceByRoomType(String loaiphong) async {
    var prices = await _room.readData('room_pricing');
    for (var price in prices) {
      if (price['loaiphong'] == loaiphong) {
        return price['gia'] as int;
      }
    }
    return 0; // Trả về 0 nếu không tìm thấy
  }

  // Cập nhật hoặc thêm giá phòng
  Future<void> updatePrice(String loaiphong, int gia) async {
    var exists = await _room.checkExists('room_pricing', 'loaiphong = ?', [loaiphong]);
    if (!exists) {
      await _room.insertData('room_pricing', {
        'loaiphong': loaiphong,
        'gia': gia,
      });
    } else {
      await _room.updateData(
        'room_pricing',
        {'gia': gia},
        'loaiphong = ?',
        [loaiphong],
      );
    }
  }

  // Xóa loại phòng
  Future<void> deletePrice(String loaiphong) async {
    await _room.deleteData('room_pricing', 'loaiphong = ?', [loaiphong]);
  }

  // Lấy tất cả giá từ room_pricing
  Future<List<Map<String, dynamic>>> getAllPrices() async {
    return await _room.readData('room_pricing');
  }

  // Lấy đường dẫn mã QR từ payment_qr (bản ghi đầu tiên)
  Future<String> getQrImage() async {
    var qrData = await _room.readData('payment_qr');
    if (qrData.isNotEmpty) {
      return qrData[0]['qr_image'] as String;
    }
    return '';
  }

  // Cập nhật đường dẫn mã QR
  Future<void> updateQrImage(String qrImage) async {
    var qrData = await _room.readData('payment_qr');
    if (qrData.isNotEmpty) {
      await _room.updateData(
        'payment_qr',
        {'qr_image': qrImage},
        'id = ?',
        [1], // Chỉ cập nhật bản ghi đầu tiên
      );
    } else {
      await _room.insertData('payment_qr', {
        'qr_image': qrImage,
      });
    }
  }

  // Insert room
  Future<int> saveRoom(Room room) async {
    return await _room.insertData('roomHotel', room.roomMap());
  }

  //read Price
  Future<List<Map<String,dynamic>>> readprice() async{
    return await _room.readPrice('room_pricing');
  }

  // Read room
  Future<List<Map<String, dynamic>>> readRoom() async {
    return await _room.readData('roomHotel');
  }

  // Insert customer
  Future<int> insertCustomer(Customer customer) async {
    return await _room.insertCustomer('customertable', customer.customerToMap());
  }

  // Read customer
  Future<List<Map<String, dynamic>>> readCustomer() async {
    return await _room.readCustomer('customertable');
  }

  Future<List<Map<String, dynamic>>> readCustomersByRoom(int idPhong) async {
    return await _room.thongtinkhachhang(idPhong);
  }

  // Xóa khách hàng khi thanh toán
  Future<void> deleteCustomer(int id) async {
    await _room.xoaCustomer(id);
  }

  Future<void> updateRoomStatus(int idPhong, String status) async {
    await _room.updateData( // Đổi thành updateData để nhất quán
      'roomHotel',
      {'status': status},
      'id = ?',
      [idPhong],
    );
  }
  // them vao lich su
    Future<int> insertHistory(Map<String, dynamic> data) async {
    return await Repository().insertHistory(data);
  }

  //xoa phong 
  Future<void> deleteData(String table, String where, List<dynamic> whereArgs) async {
  await _room.deleteData(table, where, whereArgs);
}
  
}