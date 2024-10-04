import 'package:flutter/material.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';

class EditRecordScreen extends StatefulWidget {
  final FinancialRecord record;

  const EditRecordScreen({super.key, required this.record});

  @override
  _EditRecordScreenState createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late String description, type;
  late double amount;

  @override
  void initState() {
    super.initState();
    description = widget.record.description;
    amount = widget.record.amount;
    type = widget.record.type;
  }

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'แก้ไขรายการ',
          style: TextStyle(color: Colors.white), // App bar text color set to white
        ),
        backgroundColor: Colors.black, // App bar background color set to black
        iconTheme: const IconThemeData(color: Colors.white), // Navigation icon color set to white
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Description input field
                  TextFormField(
                    initialValue: description,
                    decoration: InputDecoration(
                      labelText: 'รายละเอียด',
                      labelStyle: const TextStyle(color: Colors.black), // Label text color set to black
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black), // Focused border black
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black), // Input text color set to black
                    onChanged: (val) => description = val,
                  ),
                  const SizedBox(height: 20),
                  // Amount input field
                  TextFormField(
                    initialValue: amount.toString(),
                    decoration: InputDecoration(
                      labelText: 'จำนวนเงิน',
                      labelStyle: const TextStyle(color: Colors.black), // Label text color set to black
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black), // Focused border black
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.black), // Input text color set to black
                    onChanged: (val) => amount = double.parse(val),
                  ),
                  const SizedBox(height: 20),
                  // Dropdown for type
                  DropdownButtonFormField<String>(
                    value: type,
                    dropdownColor: const Color.fromARGB(255, 255, 255, 255), // Dropdown background color set to black
                    decoration: InputDecoration(
                      labelText: 'ประเภท',
                      labelStyle: const TextStyle(color: Colors.black), // Label text color set to black
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black), // Focused border black
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: ['รายรับ', 'รายจ่าย', 'การออม']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(
                                label,
                                style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)), // Dropdown text color set to black
                              ),
                            ))
                        .toList(),
                    onChanged: (val) => type = val!,
                    style: const TextStyle(color: Colors.black), // Selected dropdown text color set to black
                  ),
                  const SizedBox(height: 30),
                  // Save button
                  ElevatedButton(
                    onPressed: () {
                      final updatedRecord = FinancialRecord(
                        id: widget.record.id,
                        description: description,
                        amount: amount,
                        type: type,
                        date: DateTime.now(),
                      );
                      financialData.updateRecord(updatedRecord);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent, // Save button background color
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5, // Adding elevation for modern look
                      shadowColor: Colors.green.withOpacity(0.5), // Green shadow for save button
                    ),
                    child: const Text(
                      'บันทึกการเปลี่ยนแปลง',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Save button text color set to black
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Delete button
                  TextButton(
                    onPressed: () {
                      financialData.deleteRecord(widget.record.id);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(decoration: TextDecoration.underline),
                    ),
                    child: const Text(
                      'ลบรายการ',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), // Delete button text color set to red
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
