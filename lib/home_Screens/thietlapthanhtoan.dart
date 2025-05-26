import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giadienver1/database/room_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class PriceSettingsScreen extends StatefulWidget {
  const PriceSettingsScreen({super.key});

  @override
  State<PriceSettingsScreen> createState() => _PriceSettingsScreenState();
}

class _PriceSettingsScreenState extends State<PriceSettingsScreen> {
  final RoomServices _roomServices = RoomServices();
  List<Map<String, dynamic>> roomTypes = [];
  File? _qrImage;
  String? _qrImagePath;

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final prices = await _roomServices.getAllPrices();
    final qrImage = await _roomServices.getQrImage();

    File? validQrImage;
    if (qrImage != null && qrImage.isNotEmpty) {
      final file = File(qrImage);
      if (await file.exists()) {
        validQrImage = file;
      }
    }

    setState(() {
      roomTypes.clear();
      for (var price in prices) {
        roomTypes.add({
          'loaiphong': TextEditingController(text: price['loaiphong']),
          'gia': TextEditingController(text: price['gia'].toString()),
        });
      }
      if (roomTypes.isEmpty) {
        roomTypes.add({
          'loaiphong': TextEditingController(),
          'gia': TextEditingController(),
        });
      }
      _qrImagePath = validQrImage?.path;
      _qrImage = validQrImage;
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final name =
          'qr_${DateTime.now().millisecondsSinceEpoch}${extension(pickedFile.path)}';
      final savedImage = await File(pickedFile.path).copy('${directory.path}/$name');
      setState(() {
        _qrImage = savedImage;
        _qrImagePath = savedImage.path;
      });
    }
  }

  void _addRow() {
    setState(() {
      roomTypes.add({
        'loaiphong': TextEditingController(),
        'gia': TextEditingController(),
      });
    });
  }

  void _removeRow(int index) async {
    final loaiphong = roomTypes[index]['loaiphong'].text;
    if (loaiphong.isNotEmpty) {
      await _roomServices.deletePrice(loaiphong);
    }
    setState(() {
      roomTypes.removeAt(index);
    });
  }

  Future<void> _savePrices(BuildContext context) async {
    try {
      for (var room in roomTypes) {
        final loaiphong = room['loaiphong'].text;
        final giaText = room['gia'].text;
        if (loaiphong.isNotEmpty && giaText.isNotEmpty) {
          final gia = int.parse(giaText);
          if (gia > 0) {
            await _roomServices.updatePrice(loaiphong, gia);
          }
        }
      }

      if (_qrImagePath != null) {
        await _roomServices.updateQrImage(_qrImagePath!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật giá và mã QR thành công')),
      );
      await _loadPrices();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập thông tin hợp lệ')),
      );
    }
  }

  Widget _buildQrImagePreview() {
    if (_qrImage != null && _qrImage!.existsSync()) {
      return Image.file(_qrImage!, fit: BoxFit.cover);
    } else if (_qrImagePath != null && File(_qrImagePath!).existsSync()) {
      return Image.file(File(_qrImagePath!), fit: BoxFit.cover);
    } else {
      return const Center(child: Text("Chọn hình ảnh mã QR"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thiết Lập Giá Phòng')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Danh sách các hàng loại phòng và giá
              ...roomTypes.asMap().entries.map((entry) {
                int index = entry.key;
                var room = entry.value;
                return 
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: room['loaiphong'],
                        decoration: const InputDecoration(
                          labelText: 'Loại phòng',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: room['gia'],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá (VNĐ/giờ)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _removeRow(index),
                    ),
                    if (index == roomTypes.length - 1)
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addRow,
                      ),
                  ],
                ),);
                              }).toList(),



              const SizedBox(height: 30),

              // Khu vực chọn hình ảnh mã QR
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.grey[200],
                  ),
                  child: _buildQrImagePreview(),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  _savePrices(context);
                },
                child: const Text('Lưu Thiết Lập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
