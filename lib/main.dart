import 'package:flutter/material.dart';
import 'package:home_automation/Screens/BluetoothListScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home Automation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothListScreen(),
    );
  }
}


