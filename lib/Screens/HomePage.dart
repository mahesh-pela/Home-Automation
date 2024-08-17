// import 'dart:typed_data';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//
// class Homepage extends StatefulWidget {
//   const Homepage({super.key});
//
//   @override
//   State<Homepage> createState() => _HomepageState();
// }
//
// class _HomepageState extends State<Homepage> {
//   BluetoothConnection? connection;
//   BluetoothDevice? device; // This should be the device you are connecting to
//
//   @override
//   void initState() {
//     super.initState();
//     _connectToDevice();
//   }
//
//   void _connectToDevice() async {
//     // Ensure you replace `device` with the actual BluetoothDevice instance
//     if (device != null) {
//       connection = await BluetoothConnection.toAddress(device!.address);
//       print('Connected to ${device!.name}');
//     } else {
//       print('No device selected');
//     }
//   }
//
//   void _sendCommand(String command) {
//     if (connection != null && connection!.isConnected) {
//       // Convert command to Uint8List
//       Uint8List commandBytes = Uint8List.fromList(command.codeUnits);
//       connection!.output.add(commandBytes);
//       connection!.output.allSent.then((_) {
//         print('Command sent: $command');
//       });
//     } else {
//       print('Not connected to any device');
//     }
//   }
//
//   // @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Connected'),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               _sendCommand('1'); // Send command '1' to turn on the LED
//             },
//             child: Text('On'),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 textStyle:
//                 TextStyle(color: CupertinoColors.white, fontSize: 16)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               _sendCommand('0'); // Send command '0' to turn off the LED
//             },
//             child: Text('Off'),
//             style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 textStyle:
//                 TextStyle(color: CupertinoColors.white, fontSize: 16)),
//           )
//         ],
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // Close connection when widget is disposed
//     connection?.dispose();
//     super.dispose();
//   }
// }
