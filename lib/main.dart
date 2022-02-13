import 'package:firebase_core/firebase_core.dart';
import 'package:jobtest/screens/home.dart';
import 'package:jobtest/screens/login.dart';
import 'package:jobtest/screens/splash.dart';
import 'package:jobtest/utils/create_material_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

 void main() async {

  Get.log('starting services ...');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.log('All services started...');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


   @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Job Test',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color(0xff077F7B)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Splash(),
    );
  }
}
