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
      backgroundColor: Colors.white, // Set a clean white background color
      body: Stack(
        children: [
          // 🔹 Full-Screen Background Color
          Container(
            width: screenWidth,
            height: screenHeight,
            color: Colors.white, // Clean white background without an image
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

                // Lock Icon (Centered)
                const Icon(
                  Icons.lock_reset_rounded,
                  size: 80,
                  color: Color(0xFF377F7F), // Primary color for consistency
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

                // 🔹 New Password Input Field (Width Set)
                SizedBox(
                  width: screenWidth * 0.85, // Ensure consistent width for form fields
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF377F7F), width: 2),
                        borderRadius: BorderRadius.circular(12),
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

                // 🔹 Reset Password Button (Same Width as the TextField)
                SizedBox(
                  width: screenWidth * 0.85, // Matches the width of the text field
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your logic for password reset here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF377F7F), // Primary color for consistency
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
                    style: TextStyle(fontSize: 16, color: Color(0xFF377F7F), fontWeight: FontWeight.w600),
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
