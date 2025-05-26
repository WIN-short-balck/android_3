import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:giadienver1/database/room_services.dart';
import 'package:giadienver1/drawble/drawble_navigation.dart';
import 'package:giadienver1/home_Screens/thuephong_Screen.dart';
import 'package:giadienver1/home_Screens/traphong_screen.dart';
import 'package:giadienver1/models/room.dart';
import 'package:giadienver1/thongbao/thong_bao_screen.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  var _roomService = RoomServices();
  var nhanphongScreen = ThuephongScreen(idphong: -1);
  var traphongScreen = TraphongScreen(idphong: -1);
  String trangthai = "";

  var listRoom = <Room>[];

  var valueDrop = '1';

  void selcetedDropdown(String? valueNew) {
    setState(() {
      valueDrop = valueNew!;
    });
  }

  String ktra_hoatdong(String? value) {
    if (value == "0") {
      return "assets/images/ic_online.png";
    }
    return "assets/images/icon_off.png";
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Gọi phương thức để tải dữ liệu ban đầu
  }

  Future<void> _loadInitialData() async {
    await insert_room();
    await read_room();
    if (mounted) {
      setState(() {}); // Cập nhật giao diện sau khi tải dữ liệu
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerNavigation(),
      body: Column(
        children: [
          Expanded(child: _create_header(), flex: 2),
          Expanded(child: _listRoom(), flex: 8),
        ],
      ),
    );
  }

  Widget _create_header() {
    return Container(
      color: Color(0xFFFAFBF3),
      child: Builder(
        builder: (context) => Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                print("clicked");
                Scaffold.of(context).openDrawer();
              },
              child: Image.asset(
                'assets/images/logo.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
            InkWell(
              onTap: () {
                print("clicked");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManHinhThongBao(title: "manghinh thongbao"),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/chuong.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> read_room() async {
    var rooms = await _roomService.readRoom(); // List<Map<String, dynamic>>
    List<Room> tempList = [];

    for (var item in rooms) {
      var roomModel = Room(
        id: item['id'],
        name: item['name'],
        status: item['status'],
        image: item['image'],
        loaiphong: item['loaiphong'],
      );
      tempList.add(roomModel);
    }

    if (mounted) {
      setState(() {
        listRoom = tempList;
      });
    }
  }

  Future<void> insert_room() async {
    var insert = await _roomService.readRoom();

    if (insert.isEmpty) {
      var defaultRooms = <Room>[
        // Room(id: 1, image: 'assets/images/room1.jpg', name: "A1.1", status: "0"),
        // Room(id: 2, image: 'assets/images/room2.jpg', name: "A2.1", status: "0"),
        // Room(id: 3, image: 'assets/images/room3.jpg', name: "A3.1", status: "0"),
        // Room(id: 4, image: 'assets/images/room1.jpg', name: "A4.1", status: "0"),
        // Room(id: 5, image: 'assets/images/room3.jpg', name: "A5.1", status: "0"),
      ];
      for (var item in defaultRooms) {
        await _roomService.saveRoom(item);
      }
    }
  }

  Widget _listRoom() {
    return listRoom.isEmpty
        ? Center(child: CircularProgressIndicator()) // Hiển thị loading nếu danh sách trống
        : GridView.builder(
            itemCount: listRoom.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final room = listRoom[index];
              return main_list(room);
            },
          );
  }

  Widget main_list(final Room room) {
    String hd = ktra_hoatdong(room.status);
    return InkWell(
      onTap: () async {
        print('id room: ${room.id}');
        if (room.status == "0") {
          trangthai = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ThuephongScreen(idphong: room.id),
            ),
          );
          setState(() {
            room.status = trangthai;
          });
          if (trangthai == "1") {
            await _roomService.updateRoomStatus(room.id, trangthai);
          }
        } else if (room.status == "1") {
          trangthai = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TraphongScreen(idphong: room.id),
            ),
          );
          setState(() {
            room.status = trangthai;
          });
          if (trangthai == "0") {
            await _roomService.updateRoomStatus(room.id, trangthai);
          }
        }
      },
      onLongPress: () {
        _showDeleteDialog(context, room);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildRoomImage(room.image),
              Text("số phòng: ${room.name}", style: TextStyle(fontSize: 20)),
              Image.asset(hd, width: 20, height: 20, fit: BoxFit.fill),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có muốn xóa phòng ${room.name} không?'),
          actions: [
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Xóa'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteRoom(room.id);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRoom(int id) async {
    try {
      await _roomService.deleteData('roomHotel', 'id = ?', [id]);
      await read_room();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa phòng ${id} thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa phòng: $e')),
      );
    }
  }

  Widget buildRoomImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover);
    } else {
      return Image.file(
        File(imagePath),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }
  }
}