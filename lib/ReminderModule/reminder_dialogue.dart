import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class ReminderDialogue extends StatefulWidget {
  final String? reminderId;
  final String? initialTitle;
  final String? initialDescription;
  final DateTime? initialDateTime;

  const ReminderDialogue({
    Key? key,
    this.reminderId,
    this.initialTitle,
    this.initialDescription,
    this.initialDateTime,
  }) : super(key: key);

  @override
  State<ReminderDialogue> createState() => _ReminderDialogueState();
}

class _ReminderDialogueState extends State<ReminderDialogue> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  late FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _requestExactAlarmPermission();
    _initializeFirebaseMessaging();
    _initializeLocalNotifications();
    getDeviceToken();

    if (widget.reminderId != null) {
      _titleController.text = widget.initialTitle ?? '';
      _descriptionController.text = widget.initialDescription ?? '';
      _selectedDateTime = widget.initialDateTime;
    }
  }

  Future<void> getDeviceToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print("Device Token: $token");
      } else {
        print("Failed to get the device token.");
      }
    } catch (e) {
      print("Error getting device token: $e");
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
  }

  void _initializeFirebaseMessaging() {
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.requestPermission(alert: true, badge: true, sound: true);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message.notification?.title, message.notification?.body);
    });
  }

  void _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
    InitializationSettings(android: androidSettings);
    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String? title, String? body) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _localNotificationsPlugin.show(0, title, body, notificationDetails);
  }

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

  void _saveReminder() async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    if (_selectedDateTime != null && title.isNotEmpty) {
      if (widget.reminderId == null) {
        await FirebaseFirestore.instance.collection('reminders').add({
          'title': title,
          'description': description,
          'dateTime': _selectedDateTime!.toIso8601String(),
        });
      } else {
        await FirebaseFirestore.instance.collection('reminders').doc(widget.reminderId).update({
          'title': title,
          'description': description,
          'dateTime': _selectedDateTime!.toIso8601String(),
        });
      }
      print('Permission status: ${await Permission.systemAlertWindow.status}');


      if (await Permission.systemAlertWindow.isGranted) {
        try {
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
            payload: jsonEncode({"title": title, "description": description}),
          );
        } catch (e) {
          print('error coming here...: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to schedule notification: $e')),
          );
        }
      } else {
        // Request permission
        try {
          var status = await Permission.systemAlertWindow.request();
          if (status.isGranted) {
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
              payload: jsonEncode({"title": title, "description": description}),
            );
          } else {
            // Notify the user that permission is required
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('SYSTEM_ALERT_WINDOW permission is required.'),
              ),
            );
          }
        } catch (e) {
          // Log or display the error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permission request failed: $e')),
          );
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder Set Successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDateTime == null
                        ? 'No date/time selected'
                        : DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDateTime!),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text('Set Date/Time'),
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _saveReminder,
                child: const Text('Save Reminder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
