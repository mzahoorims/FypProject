import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_note/test/notification_testing.dart';
import 'SplashScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FCM Notification',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF9AA8B2),
        appBarTheme:AppBarTheme(
          backgroundColor:Color(0xFF5893BB),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  SplashScreen(),
    );
  }
}

//:  Color(0xFF5893BB),
//