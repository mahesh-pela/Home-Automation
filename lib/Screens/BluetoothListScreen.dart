import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class Bluetoothlistscreen extends StatefulWidget {
  const Bluetoothlistscreen({super.key});

  @override
  State<Bluetoothlistscreen> createState() => _Bluetoothlistscreen();
}

class _Bluetoothlistscreen extends State<Bluetoothlistscreen> {
  bool isSwitch = false;
  List<BluetoothDevice> _devicesList = [];
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
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

    // Poll for Bluetooth state change
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
      // Show loading indicator or feedback to the user
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Connecting...'),
          content: CircularProgressIndicator(),
        ),
      );

      // Attempt to connect
      await FlutterBluetoothSerial.instance.connect(device).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out');
        },
      );

      // Connection successful, navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceConnectedScreen(device: device),
        ),
      );
    } catch (e) {
      // Handle connection error
      print('Error connecting to device: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error connecting to device. Please try again.'),
        ),
      );
    } finally {
      // Dismiss loading indicator
      Navigator.of(context).pop();
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

class DeviceConnectedScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceConnectedScreen({super.key, required this.device});

  @override
  _DeviceConnectedScreenState createState() => _DeviceConnectedScreenState();
}

class _DeviceConnectedScreenState extends State<DeviceConnectedScreen> {
  BluetoothConnection? connection;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() async {
    try {
      connection = await BluetoothConnection.toAddress(widget.device.address);
      print('Connected to the device');
    } catch (e) {
      print('Error connecting to the device: $e');
    }
  }

  void _sendCommand(String command) async {
    if (connection != null && connection!.isConnected) {
      connection!.output.add(Utf8Encoder().convert(command));
      await connection!.output.allSent;
    }
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected to ${widget.device.name ?? "Unknown Device"}'),
      ),
      body: Container(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _sendCommand('1'); // Send command to turn the LED on
              },
              child: Text('On'),
            ),
            ElevatedButton(
              onPressed: () {
                _sendCommand('0'); // Send command to turn the LED off
              },
              child: Text('Off'),
            ),
          ],
        ),
      ),
    );
  }
}
