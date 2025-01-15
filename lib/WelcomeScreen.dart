import 'package:flutter/material.dart';
import 'package:student_note/regScreen.dart';


import 'loginScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
            children: [
              const SizedBox(
                height: 207,
              ),
              const Text('Hello!',
                style: TextStyle(
                  fontSize: 36.0,
                  color: Color(0xFF377F7F),
                  fontFamily: 'AlfaSlabOne',
                  shadows: [
                    Shadow(
                      offset: Offset(4.0, 4.0), // Position of the shadow
                      blurRadius: 10.0,          // Softness of the shadow
                      color: Color(0xFF000000), // Color of the shadow
                    ),
                  ],

                ),),
              const SizedBox(height: 5,),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Create your notes with us",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Color(0xFF377F7F),
                      fontFamily: 'AlfaSlabOne',
                    ),
                  )
                ],

              ),
              const SizedBox(height: 190,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const loginScreen()));
                },
                child: Container(
                  height: 60.0,
                  width: 220.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF377F7F),
                    border: Border.all(color: const Color(0xFF377F7F)),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: const Offset(3, 3), // Offset in x and y direction
                      ),
                    ],
                  ),
                  child: const Center(child: Text('Sign in',style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF)
                  ),),),
                ),
              ),
              const SizedBox(height: 20,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const RegScreen()));
                },
                child: Container(
                  height: 60.0,
                  width: 220.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF54BCBD),
                    border: Border.all(color: const Color(0xFF54BCBD)),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: const Offset(3, 3), // Offset in x and y direction
                      ),
                    ],
                  ),
                  child: const Center(child: Text('Sign up',style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF)
                  ),),),
                ),
              ),

            ]
        ),
      ),

    );
  }
}