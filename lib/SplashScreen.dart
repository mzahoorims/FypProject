import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';
import 'loginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String token = '';
  bool _isLoading = true; // Flag to control loading state

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Load the token asynchronously
  loadData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    token = sp.getString("token") ?? '';
    print('Token loaded: $token');

    setState(() {
      _isLoading = false; // Update the state to stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 6000, // Duration in milliseconds
      splash: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Notes Manager",
              style: TextStyle(
                fontSize: 36.0,
                color: Color(0xFF377F7F),
                fontFamily: 'AlfaSlabOne',
                shadows: [
                  Shadow(
                    offset: Offset(4.0, 4.0),
                    blurRadius: 10.0,
                    color: Color(0xFF000000),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20), // Add some spacing between text and animation
            Lottie.asset(
              'assets/animation/Animation - 1717493499899.json',
            ),
          ],
        ),
      ),
      nextScreen: _isLoading
          ? Container() // Show an empty container until the token is loaded
          : (token.isNotEmpty ? HomeScreen() : loginScreen()),
      splashIconSize: 500,
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
    );
  }
}
