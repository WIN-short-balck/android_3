import 'package:flutter/material.dart';
import 'package:giadienver1/database/repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> historyList = [];
  final Repository _repository = Repository();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _repository.readHistory();
    setState(() {
      historyList = data;
    });
  }

  Future<void> _confirmDeleteAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text(
              'Bạn có chắc chắn muốn xóa toàn bộ lịch sử không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _repository.deleteAllHistory();
      _loadHistory();
    }
  }

  Future<void> _confirmDeleteById(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc chắn muốn xóa bản ghi này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await _repository.deleteHistoryById(id);
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử trả phòng'),
        actions: [
          if (historyList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: _confirmDeleteAll,
            ),
        ],
      ),
      body:
          historyList.isEmpty
              ? const Center(child: Text('Chưa có lịch sử trả phòng'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: historyList.length,
                itemBuilder: (context, index) {
                  final item = historyList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text('Khách hàng: ${item['name']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phòng: ${item['id_phong']}'),
                          Text('Loại phòng: ${item['loaiphong']}'),
                          Text('SĐT: ${item['sdt'] ?? 'Chưa có'}'),
                          Text('CCCD: ${item['cccd'] ?? 'Chưa có'}'),
                          Text('Ngày vào: ${item['ngayvao'] ?? 'Chưa có'}'),
                          Text('Ngày ra: ${item['ngayra'] ?? 'Chưa có'}'),
                          Text('Thời gian thuê: ${item['thoi_gian_thue']}'),
                          Text('Thanh toán: ${item['thanh_toan']} VNĐ'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDeleteById(item['id']),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
