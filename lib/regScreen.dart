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
      body: Stack(
        children: [
          // Background Image
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/p3.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.white.withOpacity(0.5)),
          ),

          // Main Content
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 50.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("Sign Up", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 70),

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

                const Text("Already have an account?", style: TextStyle(fontSize: 16.0, color: Colors.black)),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const loginScreen())),
                  child: const Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(width: 3, color: Colors.black12),
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
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
          borderSide: const BorderSide(width: 3, color: Colors.black12),
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
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
          borderSide: const BorderSide(width: 3, color: Colors.black12),
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
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
          borderSide: const BorderSide(width: 3, color: Colors.black12),
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        suffixIcon: IconButton(
          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
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
    return GestureDetector(
      onTap: _signUp,
      child: Container(
        height: 55.0,
        width: 378.0,
        decoration: BoxDecoration(
          color: const Color(0xFF377F7F),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text("Sign Up", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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

        Fluttertoast.showToast(
          msg: "⚠️ Email is already in use. Please log in.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
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
