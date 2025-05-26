import 'package:flutter/material.dart';
import '../models/list_thong_bao.dart';

class ManHinhSuaThongBao extends StatefulWidget {
  final ThongBao thongBao;
  const ManHinhSuaThongBao({super.key, required this.thongBao});

  @override
  State<ManHinhSuaThongBao> createState() => _ManHinhSuaThongBaoState();
}

class _ManHinhSuaThongBaoState extends State<ManHinhSuaThongBao> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _nguoiDangController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.thongBao.title);
    _contentController = TextEditingController(text: widget.thongBao.noiDung);
    _nguoiDangController = TextEditingController(
      text: widget.thongBao.nguoiDang,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sửa Thông Báo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nguoiDangController,
              decoration: const InputDecoration(
                labelText: "Người đăng",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Tiêu đề",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Nội dung",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _contentController.text.isNotEmpty) {
                  final thongBaoDaSua = ThongBao(
                    id: widget.thongBao.id, // Giữ ID để cập nhật
                    nguoiDang: _nguoiDangController.text,
                    title: _titleController.text,
                    noiDung: _contentController.text,
                  );
                  Navigator.pop(context, thongBaoDaSua);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng nhập đầy đủ thông tin"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text("LƯU THAY ĐỔI"),
            ),
          ],
        ),
      ),
    );
  }
}
