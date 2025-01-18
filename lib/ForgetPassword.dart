import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  bool _obscurePassword = true; // For toggling password visibility

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Full-Screen Background Image
          Container(
            width: screenWidth,
            height: screenHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/p3.jpg'), // Ensure correct image path
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Overlay for better readability
          Container(
            width: screenWidth,
            height: screenHeight,
            color: Colors.white.withOpacity(0.7),
          ),

          // 🔹 Content on top of the background
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // App Bar with Back Button
                AppBar(
                  backgroundColor: Colors.transparent,
                  title: const Text(
                    "Forgot Password",
                    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  elevation: 0, // Remove shadow
                ),

                const SizedBox(height: 50),

                // Lock Icon
                const Icon(
                  Icons.lock_reset_rounded,
                  size: 80,
                  color: Colors.black,
                ),

                const SizedBox(height: 20),

                // Title
                const Text(
                  "Forgot your password?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle
                const Text(
                  "Enter your new password",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Password Input Field (Width Set)
                SizedBox(
                  width: screenWidth * 0.8, // Ensures consistent width
                  child: TextField(
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "New Password",
                      labelStyle: const TextStyle(color: Colors.black),
                      hintText: "Enter new password",
                      hintStyle: const TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🔹 Reset Password Button (Same Width)
                SizedBox(
                  width: screenWidth * 0.8, // Ensures button width matches text field
                  height: 53,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add logic for password reset
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF377F7F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Reset Password",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to login screen
                  },
                  child: const Text(
                    "Back to Login",
                    style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
