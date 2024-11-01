import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:io';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Request permission (especially for iOS)
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  // Initialize FCM and handle background/foreground messages
  Future<void> initializeFCM() async {
    // On iOS, request permission
    if (Platform.isIOS) {
      await requestPermission();
    }

    // Get the token for this device
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.body}');

      // Display notification using Awesome Notifications
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 10, // Add a unique id for the notification
          channelKey: 'water_reminder_channel',
          title: message.notification?.title,
          body: message.notification?.body,
        ),
      );
    });
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    
    // You can also display a notification here if needed
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'water_reminder_channel',
        title: message.notification?.title,
        body: message.notification?.body,
      ),
    );
  }
}
