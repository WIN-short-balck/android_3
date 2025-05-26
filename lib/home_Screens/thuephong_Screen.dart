import 'package:flutter/material.dart';
import 'package:giadienver1/database/room_services.dart';
import 'package:giadienver1/models/customer.dart';

class ThuephongScreen extends StatefulWidget {
  final int idphong;
  const ThuephongScreen({super.key, required this.idphong});

  @override
  State<StatefulWidget> createState() => _ThuephongScreen();
}

class _ThuephongScreen extends State<ThuephongScreen> {
  var _customerService = RoomServices();
  Customer? customer;

  DateTime? checkinTime;
  DateTime? checkoutTime;
  bool free_checkout = false;
  var nameControl = TextEditingController();
  var cccdControl = TextEditingController();
  var sdtControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Cho phép pop ngay lập tức khi nhấn phím cứng
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // Nếu đã pop, không làm gì thêm
        // Trả về "0" khi nhấn phím cứng
        Navigator.pop(context, "0");
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context, "0");
            },
          ),
        ),
        body: create_layout(),
      ),
    );
  }

  Widget create_layout() {
    return Center(
      child: Column(
        children: [
          // Họ và tên
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Họ tên: ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 8,
                child: TextField(
                  controller: nameControl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFe7e2d3),
                    hintText: "Nhập họ và tên",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // CCCD
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "CCCD: ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 8,
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  controller: cccdControl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFe7e2d3),
                    hintText: "Nhập CCCD:",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // SĐT
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "SĐT: ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 8,
                child: TextField(
                  keyboardType: TextInputType.numberWithOptions(),
                  controller: sdtControl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFe7e2d3),
                    hintText: "Nhập SĐT:",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Thời gian vào
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Vào:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(flex: 8, child: time_checkin()),
            ],
          ),

          // Thời gian ra
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Ra:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(flex: 8, child: time_checkout()),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Checkbox(
                value: free_checkout,
                onChanged: (value) {
                  setState(() {
                    free_checkout = value!;
                  });
                  if (free_checkout == true) {
                    checkoutTime = DateTime.now();
                  }
                },
              ),
              Text(
                "Chưa xác định thời gian trả phòng",
                style: TextStyle(fontSize: 15),
              ),
            ],
          ),

          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () async {
              var name = nameControl.text;
              var cccd = cccdControl.text;
              var sdt = sdtControl.text;
              var ngayvao = checkinTime;
              var ngayra = checkoutTime;
              var idphong = widget.idphong;

              if (name.isEmpty ||
                  cccd.isEmpty ||
                  sdt.isEmpty ||
                  ngayvao == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng điền đầy đủ thông tin'),
                  ),
                );
                return;
              }

              customer = Customer(
                name: name,
                sdt: sdt,
                cccd: cccd,
                ngayvao: ngayvao,
                ngayra: ngayra,
                idphong: idphong,
              );

              var result = await _customerService.insertCustomer(customer!);
              await _customerService.updateRoomStatus(widget.idphong, "1"); // Cập nhật trạng thái phòng thành "1" (đã thuê)
              Navigator.pop(context, "1");
              print("clicked");
            },
            child: Text(
              "Xác Nhận",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Thiết lập giờ vào
  Widget time_checkin() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            int yearNow = DateTime.now().year;
            DateTime? date = await showDatePicker(
              context: context,
              firstDate: DateTime(yearNow),
              lastDate: DateTime(yearNow + 10),
            ); // Thiết lập thời gian cho đồng lịch chọn

            if (date != null) {
              TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              // Thiết lập giờ phút
              if (time != null) {
                setState(() {
                  checkinTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: Text("Chọn thời gian vào"),
        ),
        Text(
          checkinTime != null ? "Vào: $checkinTime" : "chưa chọn thời gian",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Thiết lập giờ ra
  Widget time_checkout() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: free_checkout
              ? null
              : () async {
                  int yearNow = DateTime.now().year;
                  DateTime? date = await showDatePicker(
                    context: context,
                    firstDate: DateTime(yearNow),
                    lastDate: DateTime(yearNow + 10),
                  ); // Thiết lập thời gian cho đồng lịch chọn

                  if (date != null) {
                    TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    // Thiết lập giờ phút
                    if (time != null) {
                      setState(() {
                        checkoutTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
          child: Text("Chọn thời gian ra"),
        ),
        Text(
          (checkoutTime != null && free_checkout == false)
              ? "Ra: $checkoutTime"
              : "chưa chọn thời gian",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}