import 'package:flutter/material.dart';
import '../models/list_thong_bao.dart';

class ManHinhThemThongBao extends StatefulWidget {
  const ManHinhThemThongBao({super.key});

  @override
  State<ManHinhThemThongBao> createState() => _ManHinhThemThongBaoState();
}

class _ManHinhThemThongBaoState extends State<ManHinhThemThongBao> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _nguoiDangController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm Thông Báo")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nguoiDangController,
              decoration: const InputDecoration(
                labelText: "Người Đăng",
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
                    _contentController.text.isNotEmpty &&
                    _nguoiDangController.text.isNotEmpty) {
                  final thongBaoMoi = ThongBao(
                    nguoiDang: _nguoiDangController.text,
                    title: _titleController.text,
                    noiDung: _contentController.text,
                  );
                  Navigator.pop(context, thongBaoMoi);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vui lòng nhập đầy đủ thông tin"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text("THÊM"),
            ),
          ],
        ),
      ),
    );
  }
}
