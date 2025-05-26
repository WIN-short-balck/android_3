import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giadienver1/database/room_services.dart';
import 'package:giadienver1/drawble/drawble_navigation.dart';
import 'package:giadienver1/home_Screens/thuephong_Screen.dart';
import 'package:giadienver1/home_Screens/traphong_screen.dart';
import 'package:giadienver1/models/room.dart';
import 'package:giadienver1/thongbao/thong_bao_screen.dart';

class FillRoom extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FillRoom();
}

class _FillRoom extends State<FillRoom> {
  final _roomService = RoomServices();
  List<Room> listRoom = [];
  List<String> roomTypes = [];
  String selectedRoomType = "";
  Map<String, int> soPhongTrong = {};
  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    layLoaiPhongVaDem();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_firstLoad) {
      _firstLoad = false;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      layLoaiPhongVaDem();
    });
  }

  Future<void> layLoaiPhongVaDem() async {
    var prices = await _roomService.getAllPrices();
    List<String> dsLoai = prices.map((item) => item['loaiphong'] as String).toList();
    Map<String, int> dem = {for (var loai in dsLoai) loai: 0};

    var rooms = await _roomService.readRoom();
    List<Room> tempList = [];

    for (var item in rooms) {
      var room = Room(
        id: item['id'],
        name: item['name'],
        status: item['status'],
        image: item['image'],
        loaiphong: item['loaiphong'],
      );
      tempList.add(room);

      if (item['status'] == "0") {
        final loai = item['loaiphong'];
        if (dem.containsKey(loai)) {
          dem[loai] = dem[loai]! + 1;
        }
      }
    }

    setState(() {
      roomTypes = dsLoai;
      listRoom = tempList;
      soPhongTrong = dem;
      if (!roomTypes.contains(selectedRoomType) && roomTypes.isNotEmpty) {
        selectedRoomType = roomTypes.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerNavigation(),
      body: Column(
        children: [
          Expanded(child: _create_header(), flex: 2),
          Padding(
            padding: EdgeInsets.all(16),
            child: DropdownButton<String>(
              value: selectedRoomType,
              items: roomTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoomType = value!;
                });
              },
            ),
          ),
          _hienThiSoPhongTrong(),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManHinhThongBao(title: "Thông báo"),
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

  Widget _hienThiSoPhongTrong() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Phòng còn trống theo loại:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ...roomTypes.map((loai) {
          final soPhong = soPhongTrong[loai] ?? 0;
          return Text("$loai: $soPhong phòng");
        }).toList(),
      ],
    );
  }

  Widget _listRoom() {
    final filteredRooms = listRoom.where((room) => room.loaiphong == selectedRoomType).toList();
    return GridView.builder(
      itemCount: filteredRooms.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(10),
      itemBuilder: (context, index) {
        final room = filteredRooms[index];
        return main_list(room);
      },
    );
  }

  Widget main_list(Room room) {
    String hd = ktra_hoatdong(room.status);
    return InkWell(
      onTap: () async {
        if (room.status == "0") {
          String trangthai = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThuephongScreen(idphong: room.id)),
          );
          if (trangthai == "1") {
            await _roomService.updateRoomStatus(room.id, trangthai);
            await layLoaiPhongVaDem();
          }
        } else if (room.status == "1") {
          String trangthai = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TraphongScreen(idphong: room.id)),
          );
          if (trangthai == "0") {
            await _roomService.updateRoomStatus(room.id, trangthai);
            await layLoaiPhongVaDem();
          }
        }
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
              Text("Số phòng: ${room.name}", style: TextStyle(fontSize: 20)),
              Image.asset(hd, width: 20, height: 20, fit: BoxFit.fill),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoomImage(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover);
    } else {
      return Image.file(File(imagePath), width: 100, height: 100, fit: BoxFit.cover);
    }
  }

  String ktra_hoatdong(String? value) {
    return value == "0"
        ? "assets/images/ic_online.png"
        : "assets/images/icon_off.png";
  }
}
