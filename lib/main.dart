import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:water_reminder_app/screens/login_screen.dart';
import 'package:water_reminder_app/screens/splash_screen.dart';
import 'package:water_reminder_app/services/firebase_messaging_service.dart';
import 'package:water_reminder_app/themes/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart'; // Import Provider package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Check connectivity
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    // Show dialog for no internet
    runApp(MyApp(showNoInternetDialog: true));
  } else {
    // Proceed with normal initialization
    await _initializeFirebaseMessaging();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider())
        ],
        child: MyApp(),
      ),
    );
  }
}

Future<void> _initializeFirebaseMessaging() async {
  try {
    await FirebaseMessagingService().initializeFCM();
  } catch (e) {
    // Handle errors gracefully, maybe log the error or show a message
    print('Failed to initialize Firebase Messaging: $e');
  }
}

class MyApp extends StatelessWidget {
  final bool showNoInternetDialog;

  MyApp({this.showNoInternetDialog = false});

  @override
  Widget build(BuildContext context) {
    // Wrap the application in a ChangeNotifierProvider for ThemeProvider
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaAura',
      initialRoute: '/',
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/profileSetup': (context) => ProfileSetupScreen(userId: FirebaseAuth.instance.currentUser!.uid),
        '/home': (context) => HomeScreen(userId: ModalRoute.of(context)!.settings.arguments as String),
      },
      // Show the no internet dialog if required
      builder: (context, child) {
        if (showNoInternetDialog) {
          Future.delayed(Duration.zero, () {
            _showNoInternetDialog(context);
          });
        }
        return child!;
      },
    );
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please turn on your internet connection to continue.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
