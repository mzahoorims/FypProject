import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import '../test/notification_sevices.dart';

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

  Future<void> _scheduleNotificationDialog() async {
    DateTime now = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        DateTime scheduledDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        setState(() {
          _selectedDateTime = scheduledDateTime;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Notification scheduled for ${DateFormat('yyyy-MM-dd hh:mm a').format(scheduledDateTime)}",
            ),
          ),
        );

        _scheduleNotification(scheduledDateTime);
      }
    }
  }

  void _scheduleNotification(DateTime scheduledDateTime) {
    String title = _titleController.text;
    String body = _bodyController.text;

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Title and Body cannot be empty."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Duration delay = scheduledDateTime.difference(DateTime.now());

    if (delay.isNegative) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Time! Please select a future time."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Timer(delay, () {
      _notificationService.sendNotification(title, body);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your scheduled notification has been sent!"),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  final LocalNotificationService _notificationService = LocalNotificationService();
  DateTime? _selectedDateTime;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();


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
      _bodyController.text = widget.initialDescription ?? '';
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
    String description = _bodyController.text;

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
      appBar: AppBar(title: const Text('Set Reminder', style: TextStyle( fontSize: 20),),
      centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),

            Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Notification Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(26)),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Notification Body',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(26)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Body cannot be empty';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _scheduleNotificationDialog,
                  child: const Text("Schedule Notification", style: TextStyle(color: Colors.black),),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(350, 50),
                    backgroundColor: Color(0xFF5893BB),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),

            Center(
              child: ElevatedButton(
                onPressed: _saveReminder,
                child: const Text('Save Reminder', style: TextStyle(color: Colors.black),),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(350, 50),
                  backgroundColor: Color(0xFF5893BB),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
