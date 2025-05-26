import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giadienver1/database/database_helper.dart';
import 'package:giadienver1/screens_in/champion.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:giao_dien_ver1/screens_in/champion.dart';
// import 'package:giao_dien_ver1/screens_in/login.dart';
// import 'package:giao_dien_ver1/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../void/doimk.dart';
import '../void/Bottom_navigation.dart';
import '../thongbao/thong_bao_screen.dart';

class Account extends StatefulWidget {
  const Account({super.key, required this.title});
  final String title;

  @override
  State<StatefulWidget> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String _userName = 'người dùng mới';
  File? _avatarImage;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String? _loggedInEmail;

  @override
  void initState() {
    super.initState();
    _loadLoggedInEmail();
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
        child: Column(children: [Expanded(flex: 9, child: _createDoiMK())]),
      ),
    );
  }

  Widget _createDoiMK() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: InkWell(
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
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            ManHinhThongBao(title: "manghinh thongbao"),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/chuong.png',
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  _avatarImage != null
                                      ? FileImage(_avatarImage!)
                                      : AssetImage(
                                            'assets/images/default_avatar.png',
                                          )
                                          as ImageProvider,
                              child:
                                  _avatarImage == null
                                      ? Icon(Icons.account_circle, size: 60)
                                      : null,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            _userName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showEditDialog();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Đổi mật khẩu',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Divider(thickness: 1, color: Colors.grey),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChampionScreens(),
                        ),
                      );
                    },
                    child: Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    TextEditingController _controller = TextEditingController(text: _userName);
    File? _tempAvatar = _avatarImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Chỉnh sửa thông tin"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Nhập tên mới"),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (pickedFile != null) {
                        setDialogState(() {
                          _tempAvatar = File(pickedFile.path);
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          _tempAvatar != null
                              ? FileImage(_tempAvatar!)
                              : AssetImage('assets/images/default_avatar.png')
                                  as ImageProvider,
                      child:
                          _tempAvatar == null
                              ? Icon(Icons.account_circle, size: 80)
                              : null,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Nhấn để chọn ảnh mới"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Hủy"),
                ),
                TextButton(
                  onPressed: () async {
                    String newName = _controller.text.trim();
                    if (newName.isNotEmpty && _loggedInEmail != null) {
                      setState(() {
                        _userName = newName;
                        _avatarImage = _tempAvatar;
                      });
                      await _dbHelper.updateUser(
                        _loggedInEmail!,
                        newName,
                        _tempAvatar?.path,
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Lưu"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInEmail = prefs.getString('user_email');
    });
    if (_loggedInEmail != null) {
      await _loadUserAvatar();
    }
  }

  Future<void> _pickImage() async {
    if (_loggedInEmail == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
      await _dbHelper.updateUser(_loggedInEmail!, _userName, pickedFile.path);
    }
  }

  Future<void> _loadUserAvatar() async {
    if (_loggedInEmail == null) return;

    final user = await _dbHelper.getUserByEmail(_loggedInEmail!);
    if (user != null) {
      setState(() {
        _avatarImage = user.avatarPath != null ? File(user.avatarPath!) : null;
        _userName = user.name ?? _userName;
      });
    }
  }
}
