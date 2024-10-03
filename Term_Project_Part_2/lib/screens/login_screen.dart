import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teamproject_3/screens/financial_overview_screen.dart';
import 'package:teamproject_3/screens/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String identifier = '', password = '';
  String errorMessage = ''; 
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: identifier.trim())
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String email = querySnapshot.docs.first['email'];
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: identifier.trim(),
            password: password,
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FinancialOverviewScreen()),
        );
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = _getFirebaseErrorMessage(e.code);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          errorMessage = 'An unexpected error occurred: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'อีเมลไม่ถูกต้อง';
      case 'user-disabled':
        return 'บัญชีถูกปิดใช้งาน';
      case 'user-not-found':
        return 'ไม่พบผู้ใช้ที่ตรงกับอีเมลหรือชื่อผู้ใช้นี้';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง';
      default:
        return 'เกิดข้อผิดพลาด: $errorCode';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/image/bg.jpg'), // Ensure the correct path
                fit: BoxFit.cover, // Make the background image cover the screen
              ),
            ),
          ),
          // Login form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/image/LG.png',
                        height: 250,
                        width: 250,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'อีเมล หรือ ชื่อผู้ใช้',
                            labelStyle: const TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.7),
                          ),
                          style: const TextStyle(color: Colors.black),
                          onChanged: (val) => identifier = val,
                          validator: (val) =>
                              val!.isEmpty ? 'กรุณากรอกอีเมลหรือชื่อผู้ใช้' : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่าน',
                            labelStyle: const TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.7),
                          ),
                          style: const TextStyle(color: Colors.black),
                          obscureText: true,
                          onChanged: (val) => password = val,
                          validator: (val) =>
                              val!.length < 6 ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร' : null,
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (_isLoading)
                        const CircularProgressIndicator()
                      else ...[
                        SizedBox(
                          width: 300,
                          child: OutlinedButton(
                            onPressed: _signIn,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.black,
                              side: const BorderSide(
                                color: Color.fromARGB(255, 85, 85, 85),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('เข้าสู่ระบบ'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 300,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegistrationScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.black,
                              side: const BorderSide(
                                color: Color.fromARGB(255, 85, 85, 85),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('สมัครสมาชิก'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
