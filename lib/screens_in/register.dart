import 'package:flutter/material.dart';
import 'package:giadienver1/database/database_helper.dart';
import 'package:giadienver1/screens_in/verifyotp.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// Màn hình đăng ký người dùng
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Key để quản lý form validation
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Tạo mã OTP ngẫu nhiên 6 chữ số
  String _generateOTP() {
    return Random().nextInt(999999).toString().padLeft(6, '0');
  }

  // Hàm gửi OTP qua email
  Future<bool> _sendOTP(String email, String otp) async {
    // Cấu hình SMTP server (dùng Gmail làm ví dụ)
    final smtpServer = gmail('ledinhthuan27@gmail.com', 'eaho xyph wqke whpn');

    // Tạo nội dung email
    final message =
        Message()
          ..from = Address('ledinhthuan27@gmail.com', 'FLUTTER APP')
          ..recipients.add(email)
          ..subject =
              'OTP để đăng ký'
          ..text =
              'OTP của bạn là: $otp\nOTP này có hiệu lực trong 5 phút.'; // Nội dung email

    try {
      // Gửi email
      final sendReport = await send(message, smtpServer);
      print(
        'Tin nhắn đã gửi: ' + sendReport.toString(),
      ); // Thông báo gửi thành công
      return true; // Gửi thành công
    } on MailerException catch (e) {
      print('Message not sent. Error: $e'); // Thông báo lỗi nếu gửi thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không gửi được OTP. Email có thể không tồn tại hoặc có vấn đề về kết nối. Vui lòng thử lại.',
          ),
        ),
      );
      // Xóa OTP khỏi database nếu gửi thất bại
      final db = await _dbHelper.database;
      await db.delete(
        'otp_verifications',
        where: 'email = ? AND otp = ?',
        whereArgs: [email, otp],
      );
      return false; // Gửi thất bại
    }
  }

  // Xử lý đăng ký người dùng
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra lại thông tin')),
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Kiểm tra xem email đã tồn tại trong database chưa
    final emailExists = await _dbHelper.isEmailExists(email);
    if (emailExists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Email đã tồn tại!')));
      return;
    }

    // Lưu thông tin người dùng vào SQLite (chưa xác minh)
    await _dbHelper.insertUser(email, password);

    // Sinh mã OTP và lưu vào SQLite
    final otp = _generateOTP();
    await _dbHelper.saveOTP(email, otp);

    // Gửi OTP qua email và kiểm tra kết quả
    final isSent = await _sendOTP(email, otp);
    if (!isSent) {
      // Nếu gửi thất bại, không chuyển màn hình
      return;
    }
    // Chuyển đến màn hình xác minh OTP nếu gửi thành công
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerifyOTPScreen(email: email, otp: otp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 20),
                  _buildTitle(),
                  const SizedBox(height: 20),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 20),
                  _buildRegisterButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị logo
  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  // Widget hiển thị tiêu đề
  Widget _buildTitle() {
    return const Text(
      'Register',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    );
  }

  // Widget trường nhập email với validation
  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        controller: _emailController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'ENTER THE EMAIL',
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter email';
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) return 'Invalid email format';
          return null;
        },
      ),
    );
  }

  // Widget trường nhập mật khẩu với validation
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        controller: _passwordController,
        textAlign: TextAlign.center,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'ENTER THE PASSWORD',
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please enter password';
          if (value.length < 6) return 'Password must be at least 6 characters';
          return null;
        },
      ),
    );
  }

  // Widget trường xác nhận mật khẩu với validation
  Widget _buildConfirmPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        controller: _confirmPasswordController,
        textAlign: TextAlign.center,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'CONFIRM THE PASSWORD',
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Please confirm password';
          if (value != _passwordController.text)
            return 'Passwords do not match';
          return null;
        },
      ),
    );
  }

  // Widget nút đăng ký
  Widget _buildRegisterButton() {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: const Text(
          'REGISTER',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
