import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:home_automation/constants/color.dart';
import 'package:permission_handler/permission_handler.dart';
import 'DeviceConnectedScreen.dart';

BluetoothConnection? globalConnection;

class BluetoothListScreen extends StatefulWidget {
  const BluetoothListScreen({super.key});

  @override
  State<BluetoothListScreen> createState() => _BluetoothListScreenState();
}

class _BluetoothListScreenState extends State<BluetoothListScreen> {
  //state variable to verify whether the bluetooth is on/off
  bool isSwitch = false;
  List<BluetoothDevice> _devicesList = [];
  //hold the current state of the bluetooth
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _setBluetoothOffInitially();
  }

  //bluetooth state management(if bluetooth is on then it starts the scan else clears the list
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

  //requesting permission from the user
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

  // list down the paired bluetooth devices
  Future<void> _startBluetoothScan() async {
    if (isSwitch) {
      _devicesList = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {});
    }
  }

  ///----------enable or disable bluetooth-----------
  Future<void> _toggleBluetooth(bool value) async {
    if (value) {
      await FlutterBluetoothSerial.instance.requestEnable();
    } else {
      // Ensure to disconnect any existing connections
      if(globalConnection != null && globalConnection!.isConnected){
        await globalConnection!.close();
        globalConnection = null; //reset the global connection
      }
      await FlutterBluetoothSerial.instance.requestDisable();  //disable bluetooth
    }

    await Future.delayed(Duration(seconds: 2));
    await _checkBluetoothStateRepeatedly();
  }

  ///-----checks the state of the bluetooth repeatedly
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
        Navigator.pushReplacement(
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
        backgroundColor: bgColor,
        title: Text(
          'Home Automation',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: CupertinoColors.white),
        ),
        actions: [
          ///-----Button to skip the connecting process----/////
          TextButton(
            onPressed: () {
              BluetoothDevice dummyDevice = BluetoothDevice(
                address: '00:00:00:00:00:00',
                name: 'Dummy Device',
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DeviceConnectedScreen(device: dummyDevice),
                ),
              );
            },
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bluetooth', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),),
                Switch(
                  value: isSwitch,
                  onChanged: toggleSwitch,
                  activeColor: CupertinoColors.white,
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey.shade100,
                )
              ],
            ),
          ),
          Expanded(
            child: isSwitch
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
          ),
        ],
      ),



    );
  }
}

