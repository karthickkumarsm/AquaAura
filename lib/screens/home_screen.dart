import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'history_screen.dart';
import '../models/user_model.dart';
import '../widgets/my_drawer.dart';
import '../widgets/navbar.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({super.key, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double currentWaterLevel = 0.0;
  late Timer _timer;
  bool _isDialogVisible = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentWaterLevel();
    _startMidnightResetTimer();
    _checkConnectivity();
  }

  @override
  void dispose() {
    _timer.cancel();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _checkConnectivity() {
    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        // Show dialog when no internet connection
        if (!_isDialogVisible) {
          _showNoInternetDialog();
          _isDialogVisible = true;
        }
      } else {
        // Dismiss dialog if connection is back
        if (_isDialogVisible) {
          Navigator.of(context, rootNavigator: true).pop();
          _isDialogVisible = false;
        }
      }
    });
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please turn on your internet connection to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _isDialogVisible = false;
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _startMidnightResetTimer() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final duration = midnight.difference(now);

    _timer = Timer(duration, () {
      setState(() {
        currentWaterLevel = 0.0;
      });
      _saveCurrentWaterLevel();
      _startMidnightResetTimer(); // Restart the timer for the next day
    });
  }

  Future<void> _loadCurrentWaterLevel() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    if (userDoc.exists) {
      setState(() {
        currentWaterLevel = userDoc['currentWaterLevel'] ?? 0.0;
      });
    }
  }

  void increaseWater(double amount, double dailyGoal) {
    setState(() {
      currentWaterLevel += amount;
      if (currentWaterLevel > dailyGoal) {
        currentWaterLevel = dailyGoal;
      }
    });
    saveWaterIntake(amount); // Save the intake as a positive value.
  }

  void decreaseWater(double amount, double dailyGoal) async {
    if (currentWaterLevel >= amount) {
      // Show Lottie animation
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Lottie.asset('assets/assets2.json'), // Replace with Lottie animation widget
          );
        },
      );

      // Find the most recent intake entry to delete from Firestore.
      FirestoreService firestoreService = FirestoreService();
      await firestoreService.deleteLatestIntakeEntry(widget.userId, amount);

      setState(() {
        currentWaterLevel -= amount;
        if (currentWaterLevel < 0) {
          currentWaterLevel = 0;
        }
      });
      _saveCurrentWaterLevel(); // Save the updated water level

      // Hide Lottie animation
      Navigator.of(context).pop();
    }
  }

  Future<void> saveWaterIntake(double amount) async {
    FirestoreService firestoreService = FirestoreService();
    await firestoreService.addWaterIntake(widget.userId, amount);
    _saveCurrentWaterLevel(); // Save the updated water level
  }

  Future<void> _saveCurrentWaterLevel() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({'currentWaterLevel': currentWaterLevel});
  }

  double getWaterLevelPercentage(double dailyGoal) {
    return currentWaterLevel / dailyGoal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AquaAura'),
      ),
      drawer: const MyDrawer(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Failed to fetch data'));
          } else if (snapshot.hasData && snapshot.data != null) {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            double dailyGoal = userData['waterGoal'] ?? 2000.0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        width: 250,
                        height: 506,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: getWaterLevelPercentage(dailyGoal) * 500,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        child: Text(
                          '${currentWaterLevel.toInt()} ml',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      iconSize: 40,
                      onPressed: () => increaseWater(150, dailyGoal), // Increase by 250 ml
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      iconSize: 40,
                      onPressed: () => decreaseWater(150, dailyGoal), // Decrease by 250 ml
                    ),
                  ],
                ),
                Text(
                  'Daily Goal: ${dailyGoal.toInt()} ml',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: Navbar(userId: widget.userId),
    );
  }
}
