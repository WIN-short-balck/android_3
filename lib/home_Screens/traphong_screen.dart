import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giadienver1/database/room_services.dart';

class TraphongScreen extends StatefulWidget {
  final int idphong;
  const TraphongScreen({super.key, required this.idphong});

  @override
  State<TraphongScreen> createState() => _TraphongScreenState();
}

class _TraphongScreenState extends State<TraphongScreen> {
  final RoomServices _roomServices = RoomServices();
  Map<String, dynamic>? selectedCustomer;
  DateTime? checkinTime;
  DateTime? checkoutTime;
  String? loaiPhong;
  double? giaPhong;
  String? qrImagePath;

  TextEditingController nameControl = TextEditingController();
  TextEditingController cccdControl = TextEditingController();
  TextEditingController sdtControl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoomDetails();
    _loadCustomers();
  }

  Future<void> _loadRoomDetails() async {
    final room = await _roomServices.getRoomById(widget.idphong);
    if (room != null) {
      loaiPhong = room['loaiphong'];
      final price = await _roomServices.getPriceByRoomType(loaiPhong!);
      qrImagePath = await _roomServices.getQrImage();
      setState(() {
        giaPhong = price.toDouble();
      });
    }
  }

  Future<void> _loadCustomers() async {
    final data = await _roomServices.readCustomersByRoom(widget.idphong);
    if (data.isNotEmpty) {
      selectedCustomer = data[0];
      setState(() {
        nameControl.text = selectedCustomer!['name'] ?? '';
        cccdControl.text = selectedCustomer!['cccd'] ?? '';
        sdtControl.text = selectedCustomer!['sdt'] ?? '';
        checkinTime =
            selectedCustomer!['ngayvao'] != null
                ? DateTime.parse(selectedCustomer!['ngayvao'])
                : null;
        checkoutTime =
            selectedCustomer!['ngayra'] != null
                ? DateTime.parse(selectedCustomer!['ngayra'])
                : null;
      });
    }
  }

  double thanhtoan(DateTime timeIn, DateTime timeOut) {
    if (giaPhong == null) return 0;
    final duration = timeOut.difference(timeIn);
    final hour = duration.inHours;
    return giaPhong! * hour;
  }

  String timeThue(DateTime timeIn, DateTime timeOut) {
    if (timeIn != null && timeOut != null) {
      final duration = timeOut.difference(timeIn);
      final s = duration.inSeconds;
      int day = (s / 86400).toInt();
      int hours = ((s - (day * 86400)) / 3600).toInt();
      return "$day ngày/${hours} tiếng".toString();
    }
    return "";
  }

  Future<void> _confirmCheckout() async {
    if (selectedCustomer == null) return;

    // Lưu thông tin vào bảng history trước khi xóa
    await _roomServices.insertHistory({
      'name': selectedCustomer!['name'] ?? 'Không có',
      'sdt': selectedCustomer!['sdt'] ?? 'Không có',
      'cccd': selectedCustomer!['cccd'] ?? 'Không có',
      'ngayvao': selectedCustomer!['ngayvao'] ?? 'Không có',
      'ngayra': checkoutTime?.toIso8601String() ?? 'Không có',
      'id_phong': widget.idphong,
      'loaiphong': loaiPhong ?? 'Không có',
      'gia': giaPhong?.toInt() ?? 0,
      'thoi_gian_thue': timeThue(checkinTime!, checkoutTime!) ?? '',
      'thanh_toan': thanhtoan(checkinTime!, checkoutTime!).round() ?? 0,
    });

    await _roomServices.deleteCustomer(selectedCustomer!['id']);
    await _roomServices.updateRoomStatus(widget.idphong, '0');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trả phòng thành công')));
    Navigator.pop(context, "0");
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Cho phép pop ngay lập tức khi nhấn phím cứng
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Nếu đã pop, không làm gì thêm
        // Trả về "1" khi nhấn phím cứng
        Navigator.pop(context, "1");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Trả phòng'),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context, "1");
            },
          ),
        ),
        body: selectedCustomer == null
            ? const Center(child: Text('Chưa có khách hàng nào'))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoField("Họ tên", nameControl),
                    _buildInfoField("CCCD", cccdControl),
                    _buildInfoField("SĐT", sdtControl),
                    const SizedBox(height: 16),
                    _buildTimeRow("Thời gian vào", checkinTime),
                    _buildCheckoutTimePicker(),
                    const SizedBox(height: 16),
                    if (checkinTime != null && checkoutTime != null)
                      Column(
                        children: [
                          Text(
                            "Thanh toán: ${thanhtoan(checkinTime!, checkoutTime!).round()} VNĐ",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text("Thời gian đã ở: ${timeThue(checkinTime!, checkoutTime!)}")
                        ],
                      ),
                    const SizedBox(height: 20),
                    if (qrImagePath != null && qrImagePath!.isNotEmpty)
                      Column(
                        children: [
                          const Text(
                            "Quét mã QR để thanh toán:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          qrImagePath!.startsWith('assets/')
                              ? Image.asset(
                                  qrImagePath!,
                                  width: 200,
                                  height: 200,
                                )
                              : Image.file(
                                  File(qrImagePath!),
                                  width: 200,
                                  height: 200,
                                ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _confirmCheckout,
                      child: const Text(
                        "Xác Nhận Trả Phòng",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text("$label:", style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFe7e2d3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, DateTime? time) {
    return Row(
      children: [
        Text(
          "$label:",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Text(
          time != null ? time.toString() : "Chưa có thời gian",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildCheckoutTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () async {
            final now = DateTime.now();
            final pickedDate = await showDatePicker(
              context: context,
              firstDate: DateTime(now.year),
              lastDate: DateTime(now.year + 1),
              initialDate: now,
            );
            if (pickedDate != null) {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(now),
              );
              if (pickedTime != null) {
                setState(() {
                  checkoutTime = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                });
              }
            }
          },
          child: const Text("Cập nhật thời gian ra"),
        ),
        _buildTimeRow("Thời gian ra", checkoutTime),
      ],
    );
  }
}