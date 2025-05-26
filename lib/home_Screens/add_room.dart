import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giadienver1/database/room_services.dart';
import 'package:giadienver1/models/price.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/room.dart';

class AddRoom extends StatefulWidget {
  @override
  _AddRoomState createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  var listPrice = [];

  final _nameController = TextEditingController();
  File? _pickedImage;
  String chonloaiphong = "Thường";
  final List<String> loaiphongList = []; //"Thường", "Vip", "Đặc biệt"

  final roomService = RoomServices();

  Future<void> readPrice() async {
    var prices = await roomService.readprice();
    List<String> loaiPhongListTemp = [];
    for (var item in prices) {
      if (item.containsKey('loaiphong')) {
        loaiPhongListTemp.add(item['loaiphong']);
      }
    }
    setState(() {
      loaiphongList.clear();
      loaiphongList.addAll(loaiPhongListTemp);
      // nếu chonloaiphong chưa có trong danh sách thì chọn mặc định
      if (!loaiphongList.contains(chonloaiphong) && loaiphongList.isNotEmpty) {
        chonloaiphong = loaiphongList.first;
      }
    });
  }

  void xem() {
    for (var item in listPrice) {
      print("item: ${item} \n");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final name = basename(pickedFile.path);
      final savedImage = await File(
        pickedFile.path,
      ).copy('${directory.path}/$name');
      setState(() {
        _pickedImage = savedImage;
      });
    }
  }

  Future<void> _luuPhong(BuildContext context) async {
    if (_nameController.text.isEmpty || _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin và chọn ảnh!")),
      );
      return;
    }

    final room = Room(
      id: 0,
      name: _nameController.text,
      status: "0", // phòng trống
      image: _pickedImage!.path,
      loaiphong: chonloaiphong, // giờ là String
    );

    await roomService.saveRoom(room);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Đã lưu phòng thành công!")));
    print("room.image: ${room.image}");

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    readPrice(); // gọi để tải loại phòng từ DB
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Thêm Phòng Cho Thuê",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ảnh
            InkWell(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.grey[200],
                ),
                child:
                    _pickedImage != null
                        ? Image.file(_pickedImage!, fit: BoxFit.cover)
                        : Center(child: Text("Nhấn để chọn ảnh")),
              ),
            ),
            SizedBox(height: 20),
            // Tên phòng
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Tên phòng",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Loại phòng
            Row(
              children: [
                Text("Loại phòng:", style: TextStyle(fontSize: 16)),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: chonloaiphong,
                  onChanged: (value) {
                    setState(() {
                      chonloaiphong = value!;
                    });
                  },
                  items:
                      loaiphongList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _luuPhong(context);
              },
              child: Text("Lưu phòng"),
            ),
          ],
        ),
      ),
    );
  }
}
