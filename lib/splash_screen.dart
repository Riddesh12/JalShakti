import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState(){
    Timer(Duration(seconds: 4),(){
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginPage()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0f9b0f), Color(0xFF38ef7d)], // groundwater theme
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Padding(padding: EdgeInsets.all(12),
                child: Image.asset("Assets/jalshakti.png"),
              ),
            ),
            SizedBox(height: 20,),
            Text("Jal Shakti Innovators",
              style: TextStyle(fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2),),
            SizedBox(height: 15,),
            const Text(
              "Groundwater Monitoring System",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 20,),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      )
    );
  }
}
