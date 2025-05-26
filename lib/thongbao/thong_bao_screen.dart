import 'package:flutter/material.dart';
import '../models/list_thong_bao.dart';
import '../thongbao/them_thong_bao_screen.dart';
import 'sua_thong_bao_screen.dart';
import '../database/database_helper.dart';

class ManHinhThongBao extends StatefulWidget {
  const ManHinhThongBao({super.key, required this.title});
  final String title;

  @override
  State<StatefulWidget> createState() => _ManHinhThongBaoState();
}

class _ManHinhThongBaoState extends State<ManHinhThongBao> {
  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.debugThongBaoCount(); // Kiểm tra số lượng thông báo
  }

  Future<List<ThongBao>> _loadThongBao() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('thongbao', orderBy: 'id DESC');
    return result.map((json) => ThongBao.fromMap(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              flex: 9,
              child: FutureBuilder<List<ThongBao>>(
                future: _loadThongBao(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print('Lỗi FutureBuilder: ${snapshot.error}');
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print('Danh sách thông báo rỗng: ${snapshot.data}');
                    return const Center(child: Text('Không có thông báo nào'));
                  }

                  final thongbaolist = snapshot.data!;
                  print('Danh sách thông báo: $thongbaolist');
                  return _createBody_ThongBao(thongbaolist);
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(flex: 1, child: _createButton_ThongBao()),
          ],
        ),
      ),
    );
  }

  Widget _createBody_ThongBao(List<ThongBao> thongbaolist) {
    return ListView.builder(
      itemCount: thongbaolist.length,
      itemBuilder: (context, index) {
        final thongbao = thongbaolist[index];
        return GestureDetector(
          onTap: () => _showDetailDialog(thongbao),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(thongbao.title, style: const TextStyle(fontSize: 16)),
            ),
          ),
        );
      },
    );
  }

  Widget _createButton_ThongBao() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManHinhThemThongBao(),
            ),
          );

          if (result != null && result is ThongBao) {
            await DatabaseHelper.instance.insertThongBao(result);
            setState(() {});
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('+ THÊM THÔNG BÁO MỚI'),
      ),
    );
  }

  void _showDetailDialog(ThongBao thongbao) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.red),
                  ),
                ),
                Text(
                  thongbao.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(thongbao.noiDung, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Text(thongbao.nguoiDang, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await DatabaseHelper.instance.deleteThongBao(
                          thongbao.id!,
                        );
                        Navigator.pop(context);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[200],
                      ),
                      child: const Text('XÓA'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final thongBaoSua = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ManHinhSuaThongBao(thongBao: thongbao),
                          ),
                        );

                        if (thongBaoSua != null && thongBaoSua is ThongBao) {
                          await DatabaseHelper.instance.updateThongBao(
                            thongBaoSua,
                          );
                          Navigator.pop(context);
                          setState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[100],
                      ),
                      child: const Text('SỬA'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
