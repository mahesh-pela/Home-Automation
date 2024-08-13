import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  // Creating an instance of FlutterBluetoothSerial
  FlutterBluetoothSerial bluetooth = FlutterBluetoothSerial.instance;

  // Observable list to hold scan results
  RxList<BluetoothDiscoveryResult> _scanResults = <BluetoothDiscoveryResult>[].obs;

  // Getter for the scan results
  List<BluetoothDiscoveryResult> get scanResults => _scanResults;

  // Scanning for Bluetooth devices
  Future<void> scanDevices() async {
    try {
      // Clearing previous scan results
      _scanResults.clear();

      // Start scanning
      bluetooth.startDiscovery().listen((result) {
        // Adding each device found to the list
        _scanResults.add(result);
      }).onDone(() {
        // Stop scanning after discovery is done
        bluetooth.cancelDiscovery();
      });
    } catch (e) {
      print("Error during scan: $e");
    }
  }
}
