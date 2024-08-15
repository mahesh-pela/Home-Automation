import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<BluetoothDevice> _devicesList = [];
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();
    _getBluetoothState();
    _requestPermissions();
  }

  Future<void> _getBluetoothState() async {
    _bluetoothState = await FlutterBluetoothSerial.instance.state;
    setState(() {});
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

    _startBluetoothScan();
  }

  void _startBluetoothScan() async {
    if (_bluetoothState == BluetoothState.STATE_ON) {
      _devicesList = await FlutterBluetoothSerial.instance.getBondedDevices();
      setState(() {});
    } else {
      FlutterBluetoothSerial.instance.requestEnable().then((_) {
        _startBluetoothScan();
      }).catchError((error) {
        // Handle error if Bluetooth is not enabled
        print('Error enabling Bluetooth: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paired Bluetooth Devices'),
      ),
      body: _bluetoothState == BluetoothState.STATE_ON
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
          : const Center(
        child: Text('Bluetooth is not enabled.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startBluetoothScan,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}