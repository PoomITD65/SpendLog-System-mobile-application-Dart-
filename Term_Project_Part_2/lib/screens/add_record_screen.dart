import 'package:flutter/material.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';

class AddRecordScreen extends StatefulWidget {
  const AddRecordScreen({super.key});

  @override
  _AddRecordScreenState createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends State<AddRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  String description = '', type = 'รายรับ';
  double amount = 0.0;

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'เพิ่มรายการ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Set the navigation icon to white
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
          // Content form
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input for description
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'รายละเอียด',
                      labelStyle: const TextStyle(color: Colors.black), // Text color set to black
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black), // Text input color set to black
                    onChanged: (val) => description = val,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'กรุณากรอกรายละเอียด';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Input for amount
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'จำนวนเงิน',
                      labelStyle: const TextStyle(color: Colors.black), // Text color set to black
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black), // Text input color set to black
                    onChanged: (val) {
                      if (val.isNotEmpty) {
                        amount = double.tryParse(val) ?? 0.0;
                      }
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'กรุณากรอกจำนวนเงิน';
                      } else if (double.tryParse(val) == null) {
                        return 'กรุณากรอกจำนวนเงินที่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // Dropdown for type
                  DropdownButtonFormField<String>(
                    value: type,
                    dropdownColor: Colors.white, // Changed to white for visibility
                    decoration: InputDecoration(
                      labelText: 'ประเภท',
                      labelStyle: const TextStyle(color: Colors.black), // Text color set to black
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: ['รายรับ', 'รายจ่าย', 'การออม']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(
                                label,
                                style: const TextStyle(color: Colors.black), // Dropdown text color set to black
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() {
                      type = val!;
                    }),
                    style: const TextStyle(color: Colors.black), // Dropdown selected item text color set to black
                  ),
                  const SizedBox(height: 30),
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final newRecord = FinancialRecord(
                            description: description,
                            amount: amount,
                            type: type,
                            date: DateTime.now(),
                          );
                          financialData.addRecord(newRecord);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // Button background set to black
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Button text color set to white
                        ),
                      ),
                      child: const Text('บันทึก', style: TextStyle(color: Colors.white)), // Button text color set to white
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
}
