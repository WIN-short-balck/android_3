import 'package:flutter/material.dart';
import 'package:giadienver1/database/database_helper.dart';
import 'package:giadienver1/void/Bottom_navigation.dart';
import '../screens_in/forgetPass.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUserEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_email', email);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required String title});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                  _buildForgetPasswordButton(context),
                  const SizedBox(height: 20),
                  _buildLoginButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Login',
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  //nhập email
  Widget _buildEmailField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        controller: _emailController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: 'ENTER THE EMAIL',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter email';
          }
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(value)) {
            return 'Invalid email format';
          }
          return null;
        },
      ),
    );
  }

  // nhập mật khẩu
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextFormField(
        controller: _passwordController,
        textAlign: TextAlign.center,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'ENTER THE PASSWORD',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFEEEEEE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  // quên mật khẩu
  Widget _buildForgetPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () async {
  try {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ForgetPassScreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
},
      child: const Text(
        'Forget password ?',
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Colors.black,
          fontSize: 20,
        ),
      ),
    );
  }

  // NÚT LOGIN
  Widget _buildLoginButton() {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            String email = _emailController.text.trim();
            String password = _passwordController.text.trim();

            // kiểm tra email có trùng hông
            bool emailExists = await _dbHelper.isEmailExists(email);
            if(!emailExists) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email does not exist')),
              );
              return;
            }

            // kiểm tra email và mật khẩu
            bool isValid = await _dbHelper.checkLogin(email, password);

            if (isValid) {
              await saveUserEmail(email);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login successful!')),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Navigation(tile: "Home"),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid email or password')),
              );
            }
          }
          
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: const Text(
          'LOGIN',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
