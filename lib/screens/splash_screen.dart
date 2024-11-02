import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';
import '../services/firestore_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false; // Flag to prevent multiple navigations
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void checkUserStatus() async {
    if (_isNavigating) return; // Exit if already navigating
    _isNavigating = true; // Set the flag

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      AwesomeNotifications().cancelAll();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Internet Connection'),
          content: Text('Please turn on the internet to use this app.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isNavigating = false; // Reset the flag
                checkUserStatus(); // Recheck the connectivity status
              },
              child: Text('Refresh'),
            ),
          ],
        ),
      );
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool isProfileSetUp = await FirestoreService().isUserProfileSet(user.uid);
      await Future.delayed(const Duration(milliseconds: 1000)); // Optional delay for better UX
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isProfileSetUp ? HomeScreen(userId: user.uid) : ProfileSetupScreen(userId: user.uid),
        ),
      );
    } else {
      await Future.delayed(const Duration(milliseconds: 6500)); // Optional delay for better UX
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    checkUserStatus();
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (result.isNotEmpty && result.first != ConnectivityResult.none) {
        // Internet connection restored
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SplashScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Lottie.asset('assets/assets2.json'),));
  }
}
