import 'package:flutter/material.dart';
import 'package:giadienver1/database/database_helper.dart';
import 'package:giadienver1/screens_in/verifyotp.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final TextEditingController _emailController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _generateOTP() {
    return Random().nextInt(999999).toString().padLeft(6, '0');
  }

  Future<bool> _sendOTP(String email, String otp) async {
    final smtpServer = gmail('ledinhthuan27@gmail.com', 'eaho xyph wqke whpn');
    final message = Message()
      ..from = Address('ledinhthuan27@gmail.com', 'Reset Password')
      ..recipients.add(email)
      ..subject = 'OTP để đặt lại mật khẩu'
      ..text = 'OTP của bạn là: $otp\nOTP này có hiệu lực trong 5 phút.';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không gửi được OTP: $e')),
      );
      return false;
    }
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email')),
      );
      return;
    }

    final emailExists = await _dbHelper.isEmailExists(email);
    if (!emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email không tồn tại trong hệ thống')),
      );
      return;
    }

    final otp = _generateOTP();
    await _dbHelper.saveOTP(email, otp);

    final isSent = await _sendOTP(email, otp);
    if (isSent) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyOTPScreen(email: email, otp: otp,isReset: true,),
        ),
      );
    }
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
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Forget Password',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: TextField(
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'ENTER THE EMAIL',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
