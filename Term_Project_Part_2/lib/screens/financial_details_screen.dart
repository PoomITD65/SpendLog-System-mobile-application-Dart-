import 'package:flutter/material.dart';
import 'package:teamproject_3/screens/add_record_screen.dart';
import 'package:teamproject_3/screens/edit_record_screen.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';

class FinancialDetailsScreen extends StatelessWidget {
  const FinancialDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายละเอียดการเงิน',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          // Content List
          ListView.builder(
            itemCount: financialData.records.length,
            itemBuilder: (context, index) {
              final record = financialData.records[index];
              return Card(
                color: Colors.black.withOpacity(0.7),
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: ListTile(
                  title: Text(
                    '${record.type}: ${record.amount}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    record.description,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditRecordScreen(record: record)),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          financialData.deleteRecord(record.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordScreen()),
          );
        },
      ),
    );
  }
}
