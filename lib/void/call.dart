import 'package:flutter/material.dart';
import 'package:giadienver1/home_Screens/history.dart';
import '../void/call.dart';
import '../void/Bottom_navigation.dart';
import '../thongbao/thong_bao_screen.dart';
import 'package:giadienver1/database/repository.dart';

class MhSupport extends StatefulWidget {
  const MhSupport({super.key, required this.title});
  final String title;

  @override
  State<StatefulWidget> createState() => _MhSupportState();
}

class _MhSupportState extends State<MhSupport> {
  List<Map<String, dynamic>> danhSachKhachHang = [];
  List<Map<String, dynamic>> danhSachPhong = [];
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Tải dữ liệu khách hàng và phòng từ database
  void _loadData() async {
    final data = await _repository.layDanhSachLienLac();
    final dataPhong = await _repository.layDanhSachPhong();
    setState(() {
      danhSachKhachHang = data;
      danhSachPhong = dataPhong;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 16),
            _supportInfo(),
            const SizedBox(height: 16),
            Expanded(child: _danhSachKhachHang()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Navigation(tile: "manghinh home"),
              ),
            );
          },
          child: Image.asset(
            'assets/images/logo.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ManHinhThongBao(title: "manghinh thongbao"),
              ),
            );
          },
          child: Image.asset(
            'assets/images/chuong.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _supportInfo() {
    return Row(
      children: [
        Image.asset("assets/images/personSupport.png", width: 70, height: 70),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Support',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            Text(
              '1900-258-256',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        const Spacer(),
        Column(
          children: [
            IconButton(
              icon: Icon(Icons.history),
              iconSize: 35,
              tooltip: 'Xem lịch sử',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _danhSachKhachHang() {
    if (danhSachKhachHang.isEmpty || danhSachPhong.isEmpty) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    return ListView.builder(
      itemCount: danhSachKhachHang.length,
      itemBuilder: (context, index) {
        final khach = danhSachKhachHang[index];

        // Tìm thông tin phòng dựa trên id_phong
        Map<String, dynamic>? phong;
        for (var p in danhSachPhong) {
          if (p['id'] == khach['id_phong']) {
            phong = p;
            break;
          }
        }
        phong ??= {'name': 'Chưa có', 'loaiphong': 'Chưa có'};
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text('Khách:${khach['name']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Số phòng:${phong['name'] ?? 'Chưa có'}'),
                Text('Loại phòng:${phong['loaiphong'] ?? 'Chưa có'}'),
                Text('Số điện thoại:${khach['sdt'] ?? 'Chưa có'}'),
                Text('CCCD:${khach['cccd'] ?? 'Chưa có'}'),
                Text('Ngày vào:${khach['ngayvao'] ?? "Chưa có"}'),
                Text('Ngày ra:${khach['ngayra'] ?? "Chưa có"}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) async {
                if (value == 'sua') {
                  await _suaKhachHang(khach);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(value: 'sua', child: Text('Sửa')),
                  ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _suaKhachHang(Map<String, dynamic> khach) async {
    final hoTenController = TextEditingController(text: khach['name']);
    final sdtController = TextEditingController(text: khach['sdt']);
    final cccdController = TextEditingController(text: khach['cccd']);

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sửa thông tin khách hàng'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: hoTenController,
                  decoration: const InputDecoration(labelText: 'Họ tên'),
                ),
                TextField(
                  controller: sdtController,
                  decoration: const InputDecoration(labelText: 'Số điện thoại'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: cccdController,
                  decoration: const InputDecoration(labelText: 'CCCD'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Lưu'),
              ),
            ],
          ),
    );

    if (result == true) {
      // Gọi hàm update trong Repository hoặc RoomServices
      try {
        await Repository().updateData(
          'customertable',
          {
            'name': hoTenController.text,
            'sdt': sdtController.text,
            'cccd': cccdController.text,
          },
          'id = ?',
          [khach['id']],
        );
        final updatedList = await Repository().layDanhSachLienLac();
        setState(() {
          danhSachKhachHang = updatedList;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cập nhật thất bại')));
      }
    }
  }
}
