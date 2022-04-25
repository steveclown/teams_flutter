import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // backgroundColor: Color.fromARGB(255, 0, 199, 255),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/icon/background/bg-39.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 150),
                  child: Image(
                    image: AssetImage('assets/icon/03/logo-white.png'),
                    width: 150,
                    height: 150,
                  ),
                ),
                SpinKitWave(color: Colors.white, type: SpinKitWaveType.center),
                Text(
                  "Talent Management System",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
