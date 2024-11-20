import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_automation/NavigationBar/bottomNavigation.dart';
import 'package:home_automation/Screens/BluetoothListScreen.dart';
import 'package:home_automation/Screens/DeviceConnectedScreen.dart';
import 'package:home_automation/Screens/loginScreen.dart';

import 'Screens/doorLockLogs.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyADVJpLDJaOER3HGLrUqoBffLDfbnwAYu0",
        appId: "1:460827358926:android:11d2e5ab84f21ee959429f",
        messagingSenderId: "460827358926",
        projectId: "homeautomation-5391a")
  );

  runApp(
      // DevicePreview(
      // builder: (context) =>
    MyApp()
    // )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Automation',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.blue,
      ),
      home: Bottomnavigation(),
    );

  }
}


