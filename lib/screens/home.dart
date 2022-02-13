import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:jobtest/screens/login.dart';
import 'package:jobtest/screens/weather.dart';
import 'package:jobtest/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobtest/services/auth.dart' as auth;
import 'package:http/http.dart' as http;

import '../network/api.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String displayName = '';
  String? email;
  bool isVerified = false;
  String? lag, lng, _center, weatherdata;
  Position? currentLocation;


  @override
  void initState() {
    super.initState();
    _getInitData();
    getLocation();
    _determinePosition();
  }

  void _getInitData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      displayName = sharedPreferences.getString('displayName') ?? '';
      email = sharedPreferences.getString('email');
      isVerified = sharedPreferences.getBool('isVerified') ?? false;
    });
  }

  void getLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lag = position.latitude.toString();
      lng = position.longitude.toString();
      _center =
          (position.latitude.toString() + "," + position.longitude.toString());
    });
  }

  Future<String> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lag = position.latitude.toString();
      lng = position.longitude.toString();
      _center =
          (position.latitude.toString() + "," + position.longitude.toString());
    });

    return "success";
    Geolocator.getCurrentPosition();
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit an App?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                //return true when click on "Yes"
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: showExitPopup, //call function on back button press
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('My Github Page',
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              )),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.black),
            iconSize: 18,
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: displayName == null
            ? Loading()
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipPath(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 4.5,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                          image:
                              AssetImage('assets/images/the_one_ring_lotr.jpg'),
                          fit: BoxFit.cover,
                        )),
                      ),
                      clipper: ClipShape(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        email ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Divider(
                        thickness: 2.0,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () async {
                          await auth.signOut();
                          Get.off(Login());
                          Get.snackbar(
                            'Logout success!',
                            'Thanks for using app.',
                            backgroundColor: Colors.black,
                            colorText: Colors.white,
                          );
                        },
                        color: Colors.blueAccent,
                        minWidth: 300,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        child: Text('Sign Out',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white70,
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () {
                          _determinePosition();
                        },
                        color: Colors.blueAccent,
                        minWidth: 300,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        child: Text('View Lang/Long',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white70,
                            )),
                      ),
                    ),
                    _center != null
                        ? Align(
                            alignment: Alignment.center,
                            child: Text(_center.toString(),
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.black,
                                )),
                          )
                        : Text(""),
                    Align(
                      alignment: Alignment.center,
                      child: MaterialButton(
                        onPressed: () async {
                        Navigator.push(context,
                            MaterialPageRoute(
                              builder: (context) => Weather(),
                            ));

                        },
                        color: Colors.indigo,
                        minWidth: 300,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        child: Text('Check Weather',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white70,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

}

class ClipShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 1.7, size.height - 90, size.width / 1.4, size.height - 20);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height, size.width, size.height - 35);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
