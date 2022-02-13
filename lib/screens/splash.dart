import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jobtest/screens/home.dart';
import 'package:jobtest/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  @override
  _OnSplashState createState() => _OnSplashState();
}

class _OnSplashState extends State<Splash> {
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    _getInitData();
    Timer(
        Duration(seconds: 45),
        () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => isLogin ? Home() : Login())));
  }

  void _getInitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLogin = prefs.getBool('isLogin') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFF1D82FC),
                Color(0xFF1D82FC),
              ]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                SizedBox(height: 90),
                Text("Hello World",
                    style: TextStyle(fontSize: 40.0, color: Colors.white70)),
              ],
            ),
            SizedBox(height: 10),
             Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ));
                        },
                        color: Colors.teal,
                        minWidth: 300,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        child: Text('Authenticate',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white70,
                            )),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
