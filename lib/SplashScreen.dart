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
      // Update the state after loading the token
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set white background color
      body: Stack(
        children: [
          // Splash Screen Content
          AnimatedSplashScreen(
            duration: 6000, // Duration in milliseconds
            splash: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, // Center the content
                children: [
                  const Text(
                    "Notes Manager",
                    style: TextStyle(
                      fontSize: 36.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF377F7F),
                      fontFamily: 'AlfaSlabOne',
                    ),
                  ),
                  const SizedBox(height: 30), // Add more spacing between text and animation
                  Lottie.asset(
                    'assets/animation/Animation - 1717493499899.json',
                    width: 200, // Set width for better alignment
                    height: 200, // Set height for better alignment
                  ),
                ],
              ),
            ),
            nextScreen: token.isNotEmpty ? HomeScreen() : loginScreen(),
            splashIconSize: 500,
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: Colors.transparent, // Makes the background transparent
          ),
        ],
      ),
    );
  }
}
