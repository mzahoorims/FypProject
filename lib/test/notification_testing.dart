import 'package:flutter/material.dart';
import 'package:student_note/test/notification_sevices.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final LocalNotificationService _notificationService = LocalNotificationService();
  DateTime? _selectedDateTime;
  TextEditingController _titleController = TextEditingController();
  TextEditingController _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notificationService.listenNotifications();
  }

  // Function to open a dialog for date and time selection
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FCM Notification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child:

          Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Enter Notification Title',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Enter Notification Body',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _scheduleNotificationDialog,
                child: const Text("Schedule Notification"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
