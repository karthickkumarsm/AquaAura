import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this import is included
import 'package:lottie/lottie.dart';
import '../services/firestore_service.dart';
import 'package:intl/intl.dart'; // For date formatting

class HistoryScreen extends StatelessWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  Future<List<Map<String, dynamic>>> fetchWaterHistory() async {
    FirestoreService firestoreService = FirestoreService();
    return await firestoreService.getWaterIntakeHistory(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Intake History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchWaterHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Lottie.asset('assets/assets2.json'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No history available.'));
          }
          List<Map<String, dynamic>> history = snapshot.data!;

          // Group entries by date
          Map<String, List<Map<String, dynamic>>> groupedHistory = {};
          for (var entry in history) {
            DateTime date = (entry['date'] as Timestamp).toDate();
            String formattedDate = DateFormat('yyyy-MM-dd').format(date);
            if (!groupedHistory.containsKey(formattedDate)) {
              groupedHistory[formattedDate] = [];
            }
            groupedHistory[formattedDate]!.add(entry);
          }

          // Filter out entries where the net intake is zero or negative
          groupedHistory.removeWhere((date, entries) {
            double netIntake = entries.fold(0.0, (sum, entry) => sum + entry['amount']);
            return netIntake <= 0;
          });

          return ListView.builder(
            itemCount: groupedHistory.keys.length,
            itemBuilder: (context, index) {
              String date = groupedHistory.keys.elementAt(index);
              List<Map<String, dynamic>> entries = groupedHistory[date]!;

              return ExpansionTile(
                title: Text(
                  DateFormat('EEEE, MMM d, yyyy').format(DateTime.parse(date)),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: entries.map((entry) {
                  DateTime dateTime = (entry['date'] as Timestamp).toDate();
                  double amount = entry['amount'];
                  String formattedTime = DateFormat('hh:mm a').format(dateTime);
                  return ListTile(
                    title: Text('${amount.toInt()} ml'),
                    subtitle: Text(formattedTime),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}