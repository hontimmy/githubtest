import 'package:flutter/cupertino.dart';
import 'package:jobtest/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:jobtest/services/auth.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {


  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

    bool _isLoggedIn = false;

    @override
  void initState() {
    super.initState();
    checkLogin();

  }

Future<void> checkLogin() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = localStorage.getString('displayName');

    if (user != null) {
       Navigator.pop(context);
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Home(),
        ),
      );
      Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ));
      setState(() {
        _isLoggedIn = true;
      });

    } else {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Theme.of(context).primaryColorDark,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26.0, 65.0, 0, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Login Github',
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 200),
                   Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: ()  async {
                          SharedPreferences sharedPreferences =
                          await SharedPreferences.getInstance();
                      var login = await auth.signInWithGithub(context);
                      Get.snackbar(
                        'Loading...',
                        'Please wait.',
                        backgroundColor: Colors.black,
                        colorText: Colors.white,
                        showProgressIndicator: true,
                      );

                      if (login is String) {
                        Get.snackbar(
                          'Login failed!',
                          '$login',
                          backgroundColor: Colors.black,
                          colorText: Colors.white,
                        );
                      } else {
                         Navigator.pop(context);
                        Get.off(Home());
                        Get.snackbar(
                          'Login Success!',
                          'Welcome ${sharedPreferences.get('displayName')}.',
                          backgroundColor: Colors.black,
                          colorText: Colors.white,
                        );
                      }
                        },
                        color: Colors.blueAccent,
                        minWidth: 300,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        child: Text('Login with Github',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white70,
                            )),
                      ),
                    ),
                  SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
