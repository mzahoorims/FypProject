import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'FolderScreen/FolderScreen.dart';
import 'ReminderModule/ReminderScreen.dart';
import 'loginScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: const Text('Do you want to logout?', style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Confirm', style: TextStyle(fontSize: 16, color: Colors.green)),
              onPressed: () {
                _logout(); // Handle the logout action
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const loginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // More vibrant green background
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,

          tabs: const [
            Tab(icon: Icon(Icons.note, color: Colors.black,), text: 'Notes'),
            Tab(icon: Icon(Icons.alarm, color: Colors.black,), text: 'Reminder'),
          ],
          unselectedLabelColor: Colors.black, // Unselected tab color
          indicatorColor: Colors.blue, // Indicator color
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), // Change label text style
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)], // Gradient background colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            FolderScreen(),
            ReminderScreen(),

          ],
        ),
      ),
    );
  }
}
