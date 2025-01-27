import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FolderScreen/FolderScreen.dart';
import 'ReminderModule/ReminderScreen.dart';
import 'loginScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // To track selected tab index

  // Screens corresponding to each bottom navigation item
  final List<Widget> _screens = const [
    FolderScreen(),
    ReminderScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)], // Gradient background colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _screens[_selectedIndex], // Switch screens based on selected index
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF5893BB),
        currentIndex: _selectedIndex, // Highlight selected tab
        onTap: _onItemTapped, // Handle tab change
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Reminder',
          ),
        ],
      ),
    );
  }
}

//Color(0xFF377F7F),

//Color(0xFF5893BB),