// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../Controller/bluetoothController.dart';
//
// class Dashboard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth App'),
//         actions: [
//           GetX<BluetoothController>(
//             init: BluetoothController(),
//             builder: (controller) {
//               return IconButton(
//                 icon: Icon(controller.isScanning.value ? Icons.stop : Icons.search),
//                 onPressed: () {
//                   if (controller.isScanning.value) {
//                     controller.stopScan();
//                   } else {
//                     controller.startScan();
//                   }
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//       body: GetX<BluetoothController>(
//         init: BluetoothController(),
//         builder: (controller) {
//           return controller.scanResults.isNotEmpty
//               ? ListView.builder(
//             itemCount: controller.scanResults.length,
//             itemBuilder: (context, index) {
//               final result = controller.scanResults[index];
//               return Card(
//                 elevation: 2,
//                 child: ListTile(
//                   title: Text(result.device.name.isNotEmpty ? result.device.name : 'Unknown Device'),
//                   subtitle: Text(result.device.id.toString()),
//                   trailing: Text(result.rssi.toString()),
//                 ),
//               );
//             },
//           )
//               : Center(child: Text('No devices found'));
//         },
//       ),
//     );
//   }
// }
