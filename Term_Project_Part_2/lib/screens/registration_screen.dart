import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '', email = '', password = '', errorMessage = '';
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email.trim(), password: password);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': username,
          'email': email,
        });

        Navigator.pop(context);
      } on FirebaseAuthException catch (e) {
        setState(() {
          errorMessage = e.message!;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/image/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text('สมัครสมาชิก', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.black, // Ensure solid black AppBar
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'ชื่อผู้ใช้ (Username)',
                              labelStyle: const TextStyle(color: Colors.black), // Black label
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black), // Black borders
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black), // Black borders
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black), // Black text
                            onChanged: (val) => username = val,
                            validator: (val) => val!.isEmpty ? 'กรุณากรอกชื่อผู้ใช้' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'อีเมล',
                              labelStyle: const TextStyle(color: Colors.black), // Black label
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black), // Black borders
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black), // Black borders
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black), // Black text
                            onChanged: (val) => email = val,
                            validator: (val) => val!.isEmpty ? 'กรุณากรอกอีเมล' : null,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 300,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'รหัสผ่าน',
                              labelStyle: const TextStyle(color: Colors.black), // Black label
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black), // Black borders
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.black), // Black borders
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            style: const TextStyle(color: Colors.black), // Black text
                            obscureText: true,
                            onChanged: (val) => password = val,
                            validator: (val) => val!.length < 6 ? 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร' : null,
                          ),
                        ),
                        const SizedBox(height: 30),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          SizedBox(
                            width: 300,
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Black button
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 5,
                                shadowColor: Colors.black.withOpacity(0.3),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('สมัครสมาชิก', style: TextStyle(color: Colors.white)), // White text on button
                            ),
                          ),
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
          ),
        ],
      ),
    );
  }
}
