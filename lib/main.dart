import 'package:flutter/material.dart';
import 'package:home_automation/Controller/bluetoothController.dart';
import 'package:home_automation/Screens/dashBoard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LED Bluetooth',
      home: BluetoothApp(),
    );
  }
}

// class BluetoothScreen extends StatefulWidget {
//   @override
//   _BluetoothScreenState createState() => _BluetoothScreenState();
// }

// class _BluetoothScreenState extends State<BluetoothScreen> {
//   FlutterBlue flutterBlue = FlutterBlue.instance;
//   ScanResult targetDevice;
//
//   List<ScanResult> scanResults = await flutterBlue.startScan();
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold();
//   }
//
// }
