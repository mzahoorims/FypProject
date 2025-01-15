import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class TestingNotification extends StatefulWidget {
  @override
  _TestingNotificationState createState() => _TestingNotificationState();
}

class _TestingNotificationState extends State<TestingNotification> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  late FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _requestPermissions();
    _initializeFirebaseMessaging();
    _initializeLocalNotifications();
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    await Permission.notification.request();
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
  }

  // Initialize Firebase Messaging
  void _initializeFirebaseMessaging() {
    _firebaseMessaging = FirebaseMessaging.instance;

    // Request permission to show notifications (for iOS)
    _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message.notification?.title, message.notification?.body);
    });

    // Handle background and terminated state messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _showNotification(message.notification?.title, message.notification?.body);
    });
  }

  // Initialize local notifications
  void _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
    InitializationSettings(android: androidSettings);
    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  // Show local notification
  Future<void> _showNotification(String? title, String? body) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _localNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // Pick date and time for reminder
  void _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  // Save reminder and schedule notification
  void _saveReminder() async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (_selectedDateTime != null && title.isNotEmpty) {
      // Schedule notification
      await _scheduleReminderNotification(title, description);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder Set Successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields!')),
      );
    }
  }

  // Schedule a local notification at the selected date and time
  Future<void> _scheduleReminderNotification(String title, String description) async {
    try {
      if (await Permission.systemAlertWindow.isGranted) {
        await _localNotificationsPlugin.zonedSchedule(
          0,
          title,
          description,
          tz.TZDateTime.from(_selectedDateTime!, tz.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminder_channel',
              'Reminders',
              channelDescription: 'Channel for reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          payload: '{"title": "$title", "description": "$description"}',
        );
      } else {
        // Request permission
        await Permission.systemAlertWindow.request();
      }
    } catch (e) {
      print('Error scheduling notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule notification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickDateTime,
              child: Text('Pick Date & Time'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveReminder,
              child: Text('Save Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
