import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  int intervalHours = 1;
  int intervalMinutes = 0;
  bool isNotificationEnabled = true;

  @override
   void initState() {
    super.initState();
    _initializeNotifications();
    _loadSettings();
  }

  Future<void> _initializeNotifications() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'water_reminder_channel',
          channelName: 'Water Reminder Notifications',
          channelDescription: 'Notification channel for water reminders',
          defaultColor: Colors.white,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          soundSource: 'resource://raw/water'
        ),
      ],
    );

   bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      intervalHours = prefs.getInt('intervalHours') ?? 1;
      intervalMinutes = prefs.getInt('intervalMinutes') ?? 0;
      isNotificationEnabled = prefs.getBool('isNotificationEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('intervalHours', intervalHours);
    await prefs.setInt('intervalMinutes', intervalMinutes);
    await prefs.setBool('isNotificationEnabled', isNotificationEnabled);
  }

  Future<void> _scheduleRepeatingNotification() async {
    if (!isNotificationEnabled) return;

    final totalMinutes = (intervalHours * 60) + intervalMinutes;

    // Ensure total interval is within 2-hour limit
    if (totalMinutes > 179) {
      setState(() {
        intervalHours = 2;
        intervalMinutes = 59;
      });
      await _saveSettings();
    }

    // Schedule the notification
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, // Unique ID for the notification
        channelKey: 'water_reminder_channel',
        title: 'Time to Drink Water!',
        body: 'Drink a glass of water and Stay hydrated.',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
        fullScreenIntent: true,
        customSound: 'resource://raw/water',
        criticalAlert: true,
        duration: Duration(seconds: 8),
      ),
      schedule: NotificationInterval(
       interval: Duration(minutes: (intervalHours * 60) + intervalMinutes),
        preciseAlarm: true,
        repeats: true,
        allowWhileIdle: true,
      ),
    );
  }

//   Future<void> _pickCustomSound() async {
//       FilePickerResult? result = await FilePicker.platform.pickFiles();
//       if (result != null && result.files.single.path != null) {

//       setState(() {

//          customSoundPath = result.files.single.path;

//         });

//        await _saveSettings(); // Save the custom sound path to preferences
//        await _scheduleRepeatingNotification(); // Reschedule notifications with the new sound
//        if (isNotificationEnabled) {
//          await _initializeNotifications(); // Reinitialize notifications with the new sound
//        }
//     }
// }

  void _showCustomTimePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Set Reminder Interval (Max 3 Hours)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    value: intervalHours,
                    items: List.generate(3, (index) => index)
                        .map((hour) => DropdownMenuItem(
                              value: hour,
                              child: Text('$hour Hours'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        intervalHours = value ?? 1;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    value: intervalMinutes,
                    items: List.generate(60, (index) => index)
                        .map((minute) => DropdownMenuItem(
                              value: minute,
                              child: Text('$minute Minutes'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        intervalMinutes = value ?? 0;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _scheduleRepeatingNotification();
                _saveSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminder Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: isNotificationEnabled,
              onChanged: (bool value) {
                setState(() {
                  isNotificationEnabled = value;
                });
                _saveSettings();
                if (isNotificationEnabled) {
                _scheduleRepeatingNotification(); // Reschedule if enabled
                 } else {
                  AwesomeNotifications().cancelAll(); // Cancel notifications if disabled
                }
              },
            ),
            const SizedBox(height: 20),
            Lottie.asset('assets/assets3.json'),
            const SizedBox(height: 60),
            Text('Reminder Interval: Every $intervalHours Hour(s) and $intervalMinutes Minute(s)'),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
              onPressed: _showCustomTimePicker,
              child: const Text('Set Reminder Interval',style: TextStyle(color: Colors.white),),
            ),
            // const SizedBox(height: 20),
            // ElevatedButton(
            //   style: ButtonStyle(
            //           backgroundColor:
            //               MaterialStateProperty.all(Colors.lightBlue),
            //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //             RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(0),
            //             ),
            //           ),
            //         ),
            //   onPressed: _pickCustomSound,
            //   child: const Text('Pick Custom Sound',style: TextStyle(color: Colors.white),),
            // ),
            // const SizedBox(height: 10),
            // Text(customSoundPath != null ? 'Custom sound selected' : 'Using default sound'),
            
          ],
        ),
      ),
    );
  }
}
