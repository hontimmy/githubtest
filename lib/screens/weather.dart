import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:jobtest/screens/login.dart';
import 'package:jobtest/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobtest/services/auth.dart' as auth;
import 'package:http/http.dart' as http;

import '../network/api.dart';

class Weather extends StatefulWidget {
  @override
  WeatherState createState() => WeatherState();
}

class WeatherState extends State<Weather> {
  String displayName = '';
  String? email;
  bool isVerified = false;
  String? lag, lng, _center, weatherdata;
  Position? currentLocation;
  Map<String, dynamic> weather = Map<String, dynamic>();
  Map<String, dynamic> main = Map<String, dynamic>();
  Map<String, dynamic> wind = Map<String, dynamic>();

  @override
  void initState() {
    super.initState();
    _getInitData();
    _determinePosition();
  }

  void _getInitData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      lag = position.latitude.toString();
      lng = position.longitude.toString();
      _center =
          (position.latitude.toString() + "," + position.longitude.toString());
    });

    https: //api.openweathermap.org/data/2.5/weather?lat=7.784372&lon=4.5252203&cnt=1&APPID=bb46476515f81da261983d80377bc6bf
    setState(() {
      displayName = sharedPreferences.getString('displayName') ?? '';
      email = sharedPreferences.getString('email');
      isVerified = sharedPreferences.getBool('isVerified') ?? false;
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
  }

  Future<void> getWeather() async {

    var response = await http.get(
      Uri.parse("https://api.openweathermap.org/data/2.5/weather?lat=" +
          lag.toString() +
          "&lon=" +
          lng.toString() +
          "&cnt=1&appid=bb46476515f81da261983d80377bc6bf"),
      headers: <String, String>{'authorization': ""},
    );
    var resBody = json.decode(response.body);
    //print('Response body: $resBody');
    setState(() {
      weather = resBody['weather'][0];
      main = resBody['main'];
      wind = resBody['wind'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Weather Page',
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
                      onPressed: () {
                        _determinePosition();
                        getWeather();
                      },
                      color: Colors.blueAccent,
                      minWidth: 300,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 8.0),
                      child: Text('View Location Weather',
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
                 if (weather.isNotEmpty) ...[
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(children: <Widget>[
                        Text(
                          weather['main'],
                          style: TextStyle(
                            fontSize: 34,
                            color: Colors.black,
                          ),
                        ),
                      ]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text("",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              )),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height: 40),
                          Text(main['temp'].toString() + "°C",
                              style: TextStyle(
                                fontSize: 72,
                                color: Colors.black87,
                              ))
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(width: 9),
                      Text(weather['description'],
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.black87,
                          )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Text("Wind",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        )),
                                    SizedBox(height: 12),
                                    Text(wind['speed'].toString(),
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black87,
                                        )),
                                    SizedBox(height: 10),
                                    Text("m/s",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        )),
                                    SizedBox(height: 7),
                                    SizedBox(
                                      height: 2,
                                      width: 80,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Text("Pressure",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        )),
                                    SizedBox(height: 12),
                                    Text(main['pressure'].toString(),
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black87,
                                        )),
                                    SizedBox(height: 10),
                                    Text("hPa",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        )),
                                    SizedBox(height: 7),
                                    SizedBox(
                                      height: 2,
                                      width: 80,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: <Widget>[
                                    Text("Humidity",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        )),
                                    SizedBox(height: 12),
                                    Text(main['humidity'].toString(),
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.black87,
                                        )),
                                    SizedBox(height: 10),
                                    Text("%",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        )),
                                    SizedBox(height: 7),
                                    SizedBox(
                                      height: 2,
                                      width: 80,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  ] else ...[

                    ],
                ],
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
