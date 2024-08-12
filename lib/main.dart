import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:home_automation/Controller/bluetoothController.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LED Bluetooth',
      home: Bluetoothcontroller(),
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
