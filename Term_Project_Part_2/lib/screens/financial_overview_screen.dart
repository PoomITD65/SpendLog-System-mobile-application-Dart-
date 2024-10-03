import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:teamproject_3/models/financial_record.dart';
import 'package:teamproject_3/screens/financial_details_screen.dart';
import 'package:teamproject_3/screens/financial_planning_screen.dart';
import 'package:provider/provider.dart';
import 'package:teamproject_3/providers/financial_provider.dart';
import 'package:teamproject_3/screens/add_record_screen.dart';
import 'package:intl/intl.dart';
import 'package:teamproject_3/screens/UserProfileScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialOverviewScreen extends StatefulWidget {
  const FinancialOverviewScreen({super.key});

  @override
  _FinancialOverviewScreenState createState() =>
      _FinancialOverviewScreenState();
}

class _FinancialOverviewScreenState extends State<FinancialOverviewScreen> {
  bool _isLoading = true;
  String username = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFinancialData();
    });
  }

  Future<void> _fetchFinancialData() async {
    try {
      final financialData =
          Provider.of<FinancialProvider>(context, listen: false);
      await financialData.fetchRecords();

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          setState(() {
            username = userDoc['username'] ?? 'ไม่พบชื่อผู้ใช้';
          });
        }
      }
    } catch (e) {
      print('Error fetching financial data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final financialData = Provider.of<FinancialProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/image/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content over the background
          Column(
            children: [
              AppBar(
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
                backgroundColor: Colors.black,  // Set to fully black
                elevation: 0,  // Remove shadow
              ),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Expanded(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          if (financialData.records.isEmpty)
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Image.asset(
                                      'lib/assets/image/Cat_nomoney.png',
                                      height: 150,
                                      width: 150,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'ไม่มีข้อมูลการเงิน กรุณาเพิ่มรายการ',
                                    style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                ],
                              ),
                            )
                          else
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    height: 200,
                                    width: double.infinity,
                                    child: PieChart(
                                      PieChartData(
                                        sections: _createChartData(financialData.records),
                                        centerSpaceRadius: 60,
                                        sectionsSpace: 2,
                                        borderData: FlBorderData(show: false),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildButton(context, 'ดูรายละเอียด', FinancialDetailsScreen()),
                                  const SizedBox(height: 10),
                                  _buildButton(context, 'วางแผนการเงิน', FinancialPlannerApp()),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: financialData.records.length,
                                      itemBuilder: (context, index) {
                                        final record = financialData.records[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          color: Colors.grey[850],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          elevation: 5,
                                          child: ListTile(
                                            leading: Icon(
                                              record.type == 'รายรับ'
                                                  ? Icons.arrow_downward
                                                  : record.type == 'รายจ่าย'
                                                      ? Icons.arrow_upward
                                                      : Icons.savings,
                                              color: record.type == 'รายรับ'
                                                  ? Colors.green
                                                  : record.type == 'รายจ่าย'
                                                      ? Colors.red
                                                      : Colors.blue,
                                            ),
                                            title: Text(record.type,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                            subtitle: Text(
                                              '${DateFormat('dd/MM/yyyy').format(record.date)} - ${record.description}',
                                              style: const TextStyle(color: Colors.grey),
                                            ),
                                            trailing: Text(
                                              '${record.amount.toStringAsFixed(2)} บาท',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: record.type == 'รายรับ'
                                                      ? Colors.green
                                                      : record.type == 'รายจ่าย'
                                                          ? Colors.red
                                                          : Colors.blue),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordScreen()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  List<PieChartSectionData> _createChartData(List<FinancialRecord> records) {
    double totalIncome = 0;
    double totalExpenses = 0;
    double totalSavings = 0;

    for (var record in records) {
      if (record.type == 'รายรับ') {
        totalIncome += record.amount;
      } else if (record.type == 'รายจ่าย') {
        totalExpenses += record.amount;
      } else if (record.type == 'การออม') {
        totalSavings += record.amount;
      }
    }

    // คำนวณเงินที่เหลือ
    double remainingMoney = totalIncome - (totalExpenses + totalSavings);

    // สร้างข้อมูลสำหรับ PieChart
    Map<String, double> dataMap = {
      'เงินที่เหลือ': remainingMoney,
      'รายจ่าย': totalExpenses,
      'การออม': totalSavings,
    };

    // ตรวจสอบยอดรวมทั้งหมด (เงินที่เหลือ + รายจ่าย + การออม)
    final totalAmount = remainingMoney + totalExpenses + totalSavings;

    // ถ้า totalAmount เป็น 0 จะไม่แสดง Pie Chart
    if (totalAmount == 0) {
      return [];
    }

    final Map<String, Color> colorMap = {
      'เงินที่เหลือ': Colors.green,
      'รายจ่าย': Colors.red,
      'การออม': Colors.blue,
    };

    return dataMap.entries.map((entry) {
      // คำนวณเปอร์เซ็นต์ให้ถูกต้อง
      final percentage = (entry.value / totalAmount * 100).toStringAsFixed(1);
      final formattedAmount = entry.value.toStringAsFixed(2);

      String title = '${entry.key}\n$formattedAmount\n$percentage%';

      return PieChartSectionData(
        color: colorMap[entry.key]!,
        value: entry.value,
        title: title,
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildButton(BuildContext context, String text, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
