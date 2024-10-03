import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  File? _imageFile;
  Uint8List? _webImage;
  String username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        username = doc['username'] ?? 'ไม่ระบุชื่อ';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white), // White back button
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('สรุปการเงิน', style: TextStyle(color: Colors.white)),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfileScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    username.isNotEmpty ? username : 'username',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundImage: FirebaseAuth.instance.currentUser?.photoURL != null
                        ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                        : const AssetImage('lib/assets/image/profile_pic.png') as ImageProvider,
                    radius: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black, // Black AppBar
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/image/bg.jpg'), // Background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content over the background
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          backgroundImage: _getImage(),
                          radius: 60,
                          backgroundColor: Colors.grey[700],
                          child: _imageFile == null && _webImage == null && user?.photoURL == null
                              ? const Icon(Icons.person, size: 60, color: Colors.white)
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.8),
                            radius: 18,
                            child: const Icon(Icons.edit, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('บันทึกรูปโปรไฟล์', style: TextStyle(color: Colors.black)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ชื่อผู้ใช้: $username',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'อีเมล: ${user?.email ?? 'ไม่ระบุอีเมล'}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'สถานะ: ${user != null ? 'เข้าสู่ระบบแล้ว' : 'ยังไม่ได้เข้าสู่ระบบ'}',
                    style: const TextStyle(
                      fontSize: 18,
                       color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
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
                      child: const Text(
                        'ออกจากระบบ',
                        style: TextStyle(fontSize: 18, color: Colors.black), // Black text
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _getImage() {
    if (kIsWeb && _webImage != null) {
      return MemoryImage(_webImage!);
    } else if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (user?.photoURL != null) {
      return NetworkImage(user!.photoURL!);
    }
    return null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    if (kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (mounted) {
          setState(() {
            _webImage = bytes;
          });
        }
      }
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });
        }
      }
    }
  }

  Future<void> _uploadImage() async {
    if ((kIsWeb && _webImage == null) || (!kIsWeb && _imageFile == null) || user == null) return;

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_profiles/${user!.uid}.jpg');
      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = storageRef.putData(_webImage!);
      } else {
        uploadTask = storageRef.putFile(_imageFile!);
      }

      final snapshot = await uploadTask;
      final photoURL = await snapshot.ref.getDownloadURL();

      await user!.updatePhotoURL(photoURL);
      await user!.reload();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }
}
