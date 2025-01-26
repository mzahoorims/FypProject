import 'package:flutter/material.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
        centerTitle: true,
      ),
    // Set a clean white background color
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            const SizedBox(height: 50),

            // Email Input Field
            SizedBox(
              width: screenWidth * 0.85, // Ensure consistent width for form fields
              child: TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Enter your email",
                  labelStyle: const TextStyle(color: Colors.black),
                  hintText: "Enter your email",
                  hintStyle: const TextStyle(color: Colors.black54),
                  filled: true,
                  fillColor: Color(0xFF939FAD),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF377F7F), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.email, color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Reset Password Button (Same Width as the TextField)
            SizedBox(
              width: screenWidth * 0.85, // Matches the width of the text field
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // Add your logic for sending the password reset email here
                  String email = _emailController.text.trim();
                  if (email.isNotEmpty) {
                    // For example: Call Firebase Auth to reset the password
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password reset link sent!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please enter your email")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5893BB),// Primary color for consistency
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Send",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Back to Login
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
    );
  }
}
