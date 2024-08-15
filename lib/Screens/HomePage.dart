// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);
//
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   List<BluetoothDevice> _devicesList = [];
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
//   bool _isBluetoothEnabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissions();
//     _getBluetoothState();
//   }
//
//   Future<void> _getBluetoothState() async {
//     _bluetoothState = await FlutterBluetoothSerial.instance.state;
//     setState(() {
//       _isBluetoothEnabled = _bluetoothState == BluetoothState.STATE_ON;
//     });
//     if (_isBluetoothEnabled) {
//       _startBluetoothScan();
//     } else {
//       _devicesList = []; // Clear the list if Bluetooth is off
//     }
//   }
//
//   Future<void> _requestPermissions() async {
//     if (await Permission.bluetooth.isDenied) {
//       await Permission.bluetooth.request();
//     }
//
//     if (await Permission.bluetoothScan.isDenied) {
//       await Permission.bluetoothScan.request();
//     }
//
//     if (await Permission.bluetoothConnect.isDenied) {
//       await Permission.bluetoothConnect.request();
//     }
//
//     if (await Permission.locationWhenInUse.isDenied) {
//       await Permission.locationWhenInUse.request();
//     }
//
//     if (await Permission.bluetooth.isPermanentlyDenied ||
//         await Permission.bluetoothScan.isPermanentlyDenied ||
//         await Permission.bluetoothConnect.isPermanentlyDenied ||
//         await Permission.locationWhenInUse.isPermanentlyDenied) {
//       openAppSettings();
//     }
//   }
//
//   Future<void> _startBluetoothScan() async {
//     if (_isBluetoothEnabled) {
//       _devicesList = await FlutterBluetoothSerial.instance.getBondedDevices();
//       setState(() {});
//     } else {
//       _devicesList = []; // Ensure the list is empty if Bluetooth is off
//       setState(() {});
//     }
//   }
//
//   Future<void> _toggleBluetooth(bool value) async {
//     if (value) {
//       await FlutterBluetoothSerial.instance.requestEnable();
//     } else {
//       await FlutterBluetoothSerial.instance.requestDisable();
//     }
//     await Future.delayed(Duration(seconds: 1)); // Wait for Bluetooth state to update
//     _getBluetoothState(); // Refresh the state and device list
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Bluetooth Devices'),
//         actions: [
//           Switch(
//             value: _isBluetoothEnabled,
//             onChanged: (value) {
//               _toggleBluetooth(value);
//             },
//           ),
//         ],
//       ),
//       body: _isBluetoothEnabled
//           ? ListView.builder(
//         itemCount: _devicesList.length,
//         itemBuilder: (context, index) {
//           BluetoothDevice device = _devicesList[index];
//           return ListTile(
//             title: Text(device.name ?? "Unknown Device"),
//             subtitle: Text(device.address),
//             onTap: () {
//               // Implement device selection
//             },
//           );
//         },
//       )
//           : const Center(
//         child: Text('Bluetooth is turned off.'),
//       ),
//       floatingActionButton: _isBluetoothEnabled
//           ? FloatingActionButton(
//         onPressed: _startBluetoothScan,
//         child: const Icon(Icons.refresh),
//       )
//           : null,
//     );
//   }
// }
