import 'dart:async';

import 'package:flutter/material.dart';

// my own packages
import './pages/home.dart';

main() {
  runApp(new MaterialApp(
    title: "Semoney",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.blue.shade900,
    ),
    home: Home(),
  ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            color: Colors.white,
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset("icon/smm.png",
                    width: 100.0,
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Text("Semoney", style: TextStyle(color: Colors.blue.shade900, fontSize: 24.0, fontWeight: FontWeight.bold),),
                    ),

                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade900),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text("waste no money!", style: TextStyle(color: Colors.grey),)
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    Timer(Duration(seconds: 3), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Home()));
    });
  }
}





//
//
