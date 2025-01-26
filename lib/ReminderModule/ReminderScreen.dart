import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:student_note/ReminderModule/reminder_dialogue.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  void _deleteReminder(String id) async {
    await FirebaseFirestore.instance.collection('reminders').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       // backgroundColor: Colors.pink.shade50,
        title: const Text('Reminders'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('reminders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Reminders Found'));
          }

          final reminders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final data = reminders[index].data() as Map<String, dynamic>;
              final id = reminders[index].id;

              return Card(
                color: Color(0xFF939FAD),
                elevation: 5,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(data['title']),
                  subtitle: Text(data['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReminderDialogue(
                                reminderId: id,
                                initialTitle: data['title'],
                                initialDescription: data['description'],
                                initialDateTime: DateTime.parse(data['dateTime']),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteReminder(id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ReminderDialogue()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
