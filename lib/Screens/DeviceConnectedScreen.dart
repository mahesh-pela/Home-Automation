import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'BluetoothListScreen.dart';

class DeviceConnectedScreen extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceConnectedScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected to ${device.name ?? "Unknown Device"}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _sendMessageToBluetooth('1'); // Send '1' to turn on the LED
              },
              child: Text('ON'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _sendMessageToBluetooth('0'); // Send '0' to turn off the LED
              },
              child: Text('OFF'),
            ),
          ],
        ),
      ),
    );
  }

  //sends message to the bluetooth to control the led
  Future<void> _sendMessageToBluetooth(String message) async {
    try {
      if (globalConnection != null && globalConnection!.isConnected) {
        globalConnection!.output.add(Uint8List.fromList(utf8.encode(message)));
        await globalConnection!.output.allSent;
      }
    } catch (e) {
      print('Error sending message to device: $e');
    }
  }
}