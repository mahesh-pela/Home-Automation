import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue/flutter_blue.dart';

Future<void> requestPermissions(FlutterBlue flutterBlue) async {
  if (await Permission.bluetoothScan.request().isGranted &&
      await Permission.bluetoothConnect.request().isGranted &&
      await Permission.location.request().isGranted) {
    // Permissions granted, proceed with Bluetooth scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));
  } else {
    // Handle the case when permissions are denied
    print('Bluetooth permissions not granted.');
  }
}
