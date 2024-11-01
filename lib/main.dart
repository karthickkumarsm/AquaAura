import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:water_reminder_app/screens/login_screen.dart';
import 'package:water_reminder_app/screens/splash_screen.dart';
import 'package:water_reminder_app/services/firebase_messaging_service.dart';
import 'package:water_reminder_app/themes/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'screens/reminder_screen.dart'; 
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
       channelKey: 'water_reminder_channel',
        channelName: 'Water Reminder Notifications',
        channelDescription: 'Notification channel for water reminders',
        defaultColor: Colors.white,
        ledColor: Colors.white,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
        importance: NotificationImportance.High,
        soundSource: 'resource://raw/water',
      ),
    ],
  );
   bool isAllowedToSendNotification = await AwesomeNotifications().isNotificationAllowed();
  if(!isAllowedToSendNotification){
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessagingService().initializeFCM();
  runApp(
    MultiProvider(
     providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider())
     ],
    child: MyApp()
    ),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
