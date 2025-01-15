import 'package:flutter/material.dart';

class ForgetPassword extends StatelessWidget{
  const ForgetPassword({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF54BCBD),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 160, left: 30),
              child: const Text(
                "Forget your password?",
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
            ),
            const SizedBox(height: 5,),
            Container(
                padding: const EdgeInsets.only(top: 2, left: 30),
              child:
                Text("Enter your new password sent in your email",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Color(0xFF377F7F),
                    fontFamily: 'AlfaSlabOne',
                  ),
                )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 18.0, right: 18.0),
              child: Column(
                children: [
                  const SizedBox(height: 2),
                  TextField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 3, color: Colors.black12),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: Icon(Icons.visibility_outlined, color: Colors.grey),
                      hintText: 'Password',
                    ),
                  ),
                  SizedBox(height: 100,),
                  GestureDetector(
                    onTap: (){},
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
                      child: const Center(child: Text('Send',style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF)
                      ),),),
                    ),

                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
