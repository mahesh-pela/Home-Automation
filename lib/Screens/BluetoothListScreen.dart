import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

BluetoothConnection? globalConnection;

class BluetoothListScreen extends StatefulWidget {
  const BluetoothListScreen({super.key});

  @override
  State<BluetoothListScreen> createState() => _BluetoothListScreenState();
}

class _BluetoothListScreenState extends State<BluetoothListScreen> {
  bool isSwitch = false;
  List<BluetoothDevice> _devicesList = [];
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _setBluetoothOffInitially();
  }

  Future<void> _getBluetoothState() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    setState(() {
      isSwitch = _bluetoothState == BluetoothState.STATE_ON;
      if (isSwitch) {
        _startBluetoothScan();
      } else {
        _devicesList = [];
      }
    });
  }

  Future<void> _requestPermissions() async {
    if (await Permission.bluetooth.isDenied) {
      await Permission.bluetooth.request();
    }

    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }

    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }

    if (await Permission.locationWhenInUse.isDenied) {
      await Permission.locationWhenInUse.request();
    }

    if (await Permission.bluetooth.isPermanentlyDenied ||
        await Permission.bluetoothScan.isPermanentlyDenied ||
        await Permission.bluetoothConnect.isPermanentlyDenied ||
        await Permission.locationWhenInUse.isPermanentlyDenied) {
      openAppSettings();
    }

    await _getBluetoothState();
  }

  Future<void> _setBluetoothOffInitially() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    if (_bluetoothState == BluetoothState.STATE_ON) {
      await FlutterBluetoothSerial.instance.requestDisable();
      setState(() {
        isSwitch = false;
      });
    }
  }

  Future<void> _startBluetoothScan() async {
    if (isSwitch) {
      _devicesList = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {});
    }
  }

  Future<void> _toggleBluetooth(bool value) async {
    if (value) {
      await FlutterBluetoothSerial.instance.requestEnable();
    } else {
      await FlutterBluetoothSerial.instance.requestDisable();
    }

    await Future.delayed(Duration(seconds: 2));
    await _checkBluetoothStateRepeatedly();
  }

  Future<void> _checkBluetoothStateRepeatedly() async {
    while (true) {
      _bluetoothState = await FlutterBluetoothSerial.instance.state;
      if (_bluetoothState == (isSwitch ? BluetoothState.STATE_ON : BluetoothState.STATE_OFF)) {
        await _getBluetoothState();
        break;
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  void toggleSwitch(bool value) {
    setState(() {
      isSwitch = value;
    });
    _toggleBluetooth(value);
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      globalConnection = await BluetoothConnection.toAddress(device.address).timeout(
        Duration(seconds: 20), // Increased timeout
        onTimeout: () {
          throw TimeoutException("Connection timeout!");
        },
      );
      if (globalConnection!.isConnected) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeviceConnectedScreen(device: device),
          ),
        );
        print('Connected to ${device.name}');
      }
    } catch (e) {
      print('Error connecting to device: $e');
      // Retry logic
      Future.delayed(Duration(seconds: 5), () {
        _connectToDevice(device); // Retry after 5 seconds
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Home Automation',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          Switch(
            value: isSwitch,
            onChanged: toggleSwitch,
            activeColor: CupertinoColors.white,
            activeTrackColor: Colors.orange,
            inactiveTrackColor: Colors.grey.shade300,
          )
        ],
      ),
      body: isSwitch
          ? ListView.builder(
        itemCount: _devicesList.length,
        itemBuilder: (context, index) {
          BluetoothDevice device = _devicesList[index];
          return ListTile(
            title: Text(device.name ?? "Unknown Device"),
            subtitle: Text(device.address),
            onTap: () => _connectToDevice(device),
          );
        },
      )
          : Center(
        child: Text('Bluetooth is Off'),
      ),
    );
  }
}

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
            Text('Successfully connected to ${device.name ?? "Unknown Device"}'),
          ],
        ),
      ),
    );
  }

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
