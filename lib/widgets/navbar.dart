import 'package:flutter/material.dart';
import 'package:water_reminder_app/screens/history_screen.dart';
import 'package:water_reminder_app/screens/reminder_screen.dart';
import '../screens/settings_screen.dart';

class Navbar extends StatelessWidget {
  final String userId;

  const Navbar({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen(userId: userId)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.alarm),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReminderScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen(userId: userId)),
              );
            },
          ),
        ],
      ),
    );
  }
}
