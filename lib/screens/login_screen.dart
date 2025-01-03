import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:water_reminder_app/services/firebase_auth_service.dart';


class LoginScreen extends StatelessWidget {
  final FirebaseAuthService _authService = FirebaseAuthService();

  LoginScreen({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await _authService.signInWithGoogle();
      Navigator.pushReplacementNamed(context, '/');
    } catch (error) {
      print('Login error: $error');
      // Handle login error (e.g., show a message to the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/assets1.json'),
            const SizedBox(height: 16.0),
            const Text(
              'Welcome to AquaAura!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
             const SizedBox(height: 16.0),
            const Text(
              'Get Started by signing in.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
              icon: Image.asset('assets/google.png', height: 40, width: 40,), // Use a different icon as Icons.google does not exist
              onPressed: () => _signInWithGoogle(context),
              label: const Text('Sign in with Google', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
