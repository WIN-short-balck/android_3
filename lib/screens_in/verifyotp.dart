import 'package:flutter/material.dart';
import 'package:giadienver1/database/database_helper.dart';
import 'package:giadienver1/screens_in/reset_pass.dart';
import 'package:giadienver1/screens_in/login.dart';

// Màn hình xác minh mã OTP
class VerifyOTPScreen extends StatefulWidget {
  final String email;
  final String otp;
  final bool isReset;

  const VerifyOTPScreen({
    super.key,
    required this.email,
    required this.otp,
    this.isReset = false,
  });

  @override
  State<VerifyOTPScreen> createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  final _otpController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Xử lý xác minh mã OTP
  Future<void> _verifyOTP() async {
    final inputOTP = _otpController.text.trim();
    final isValid = await _dbHelper.verifyOTP(
      widget.email,
      inputOTP,
    ); // Kiểm tra OTP có hợp lệ không

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP không hợp lệ hoặc hết hạn')),
      );
      return;
    }
    if (widget.isReset) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: widget.email),
        ),
      );
    }
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(title: 'Login'),
        ),
      );
    }

    // Đánh dấu email là đã xác minh trong database
    await _dbHelper.xacminhEmail(widget.email);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email đã được xác minh thành công!')),
    );

  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBF3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verify OTP',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    controller: _otpController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'ENTER THE OTP',
                      filled: true,
                      fillColor: const Color(0xFFEEEEEE),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text(
                      'VERIFY',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
