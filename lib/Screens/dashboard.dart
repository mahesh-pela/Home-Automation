import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isSwitch = false;
  // String textValue = 'Bluetooth is Off';
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
      // textValue = isSwitch ? 'Bluetooth is On' : 'Bluetooth is Off';
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
      // textValue = isSwitch ? 'Bluetooth is On' : 'Bluetooth is Off';
    });
    _toggleBluetooth(value);
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
            onTap: () {
              // Implement device selection
            },
          );
        },
      )
          : Center(
        // child: Text(textValue),
      ),
    );
  }
}
