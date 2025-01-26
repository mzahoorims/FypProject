import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'HomeScreen.dart';
import 'authentication/firebase_auth_services.dart';
import 'loginScreen.dart';

class RegScreen extends StatefulWidget {
  const RegScreen({Key? key}) : super(key: key);

  @override
  _RegScreenState createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  final firebaseAuthService _auth = firebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("Sign Up", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
        child: Column(
          children: [
            const SizedBox(height: 40),

            _buildTextField(_usernameController, Icons.person, 'User name'),
            const SizedBox(height: 20),
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 20),
            _buildConfirmPasswordField(),
            const SizedBox(height: 70),

            _buildSignUpButton(),
            const SizedBox(height: 15),

            const Text(
              "Already have an account?",
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const loginScreen()),
              ),
              child: const Text(
                "Sign In",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.black
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint) {
    return
      TextField(
      controller: controller,
      decoration: InputDecoration(

        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide( color: Colors.black),
          borderRadius: BorderRadius.circular(20.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x6C000000)), // Blue border on focus
          borderRadius: BorderRadius.circular(20.0),
        ),
        filled: true,
        fillColor: Color(0xFF939FAD),
        suffixIcon: Icon(icon, color: Colors.black54),
        hintText: hint,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(20.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x6C000000)), // Blue border on focus
          borderRadius: BorderRadius.circular(20.0),
        ),
        filled: true,
        fillColor: Color(0xFF939FAD),
        suffixIcon: const Icon(Icons.email, color: Colors.black54),
        hintText: "Enter email",
        errorText: _emailError,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(20.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x6C000000)), // Blue border on focus
          borderRadius: BorderRadius.circular(20.0),
        ),
        filled: true,
        fillColor: Color(0xFF939FAD),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black45),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        hintText: "Password",
        errorText: _passwordError,
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide( color: Colors.black),
          borderRadius: BorderRadius.circular(20.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0x6C000000)), // Blue border on focus
          borderRadius: BorderRadius.circular(20.0),
        ),

        filled: true,
        fillColor: Color(0xFF939FAD),
        suffixIcon: IconButton(
          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.black45),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        hintText: "Confirm Password",
        errorText: _confirmPasswordError,
      ),
    );
  }

  Widget _buildSignUpButton() {
    return

      GestureDetector(
        onTap: _signUp,
        child:
        Container(
          height: 55.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF5893BB),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      );
  }

  void _signUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Reset error messages
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate the inputs
    if (email.isEmpty) {
      setState(() {
        _emailError = "Please fill the required field";
      });
      return;
    }
    if (password.isEmpty) {
      setState(() {
        _passwordError = "Please fill the required field";
      });
      return;
    }
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = "Please fill the required field";
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _passwordError = "Password should be at least 6 characters";
      });
      return;
    }

    // Check for uppercase letter and special character
    RegExp uppercaseRegExp = RegExp(r'[A-Z]');
    RegExp specialCharRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

    bool containsUppercase = uppercaseRegExp.hasMatch(password);
    bool containsSpecialChar = specialCharRegExp.hasMatch(password);

    if (!containsUppercase && !containsSpecialChar) {
      setState(() {
        _passwordError = "Use at least one special character and one uppercase letter";
      });
      return;
    } else if (!containsUppercase) {
      setState(() {
        _passwordError = "Use at least one uppercase letter";
      });
      return;
    } else if (!containsSpecialChar) {
      setState(() {
        _passwordError = "Use at least one special character";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = "Passwords are not the same";
      });
      return;
    }

    // Ensure email is from gmail.com domain
    if (!email.endsWith('@gmail.com')) {
      setState(() {
        _emailError = 'Email must be a @gmail.com address';
      });
      return;
    }

    // Attempt to create the user with Firebase Auth
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create a folder node for the user in Firebase
      final userId = userCredential.user!.uid;
      await FirebaseDatabase.instance.ref('users/$userId/folders').set({});

      Fluttertoast.showToast(
        msg: "✅ Account created successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        setState(() {
          _emailError = "⚠️ Email is already in use. Please log in.";
        });
      } else {
        Fluttertoast.showToast(
          msg: "❌ Error: ${e.message}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }
  }
}
