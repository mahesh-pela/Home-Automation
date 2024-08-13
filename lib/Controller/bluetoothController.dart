import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:home_automation/Controller/permission_handler.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MaterialApp(home: BluetoothApp()));
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
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

  // Start scanning for devices
  void startScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    }).onDone(() {
      flutterBlue.stopScan();
    });
  }

  // Connect to a specific device
  void connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      _connectedDevice = device;
    });
    discoverServices();
  }

  // Disconnect from a device
  void disconnectFromDevice() async {
    await _connectedDevice?.disconnect();
    setState(() {
      _connectedDevice = null;
      _services.clear();
    });
  }

  // Discover services offered by the connected device
  void discoverServices() async {
    if (_connectedDevice == null) return;
    List<BluetoothService> services = await _connectedDevice!.discoverServices();
    setState(() {
      _services = services;
    });

    // Example: Print all characteristics of each service
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        print('Characteristic: ${characteristic.uuid}');
      }
    }
  }

  // Read characteristics
  void readCharacteristic(BluetoothCharacteristic characteristic) async {
    List<int> value = await characteristic.read();
    print('Read value: $value');
  }

  // Write to characteristics
  void writeCharacteristic(BluetoothCharacteristic characteristic, List<int> value) async {
    await characteristic.write(value);
    print('Written value: $value');
  }

  // Read descriptors
  void readDescriptor(BluetoothDescriptor descriptor) async {
    List<int> value = await descriptor.read();
    print('Read descriptor value: $value');
  }

  // Write to descriptors
  void writeDescriptor(BluetoothDescriptor descriptor, List<int> value) async {
    await descriptor.write(value);
    print('Written descriptor value: $value');
  }

  // Set notifications and listen to changes
  void setNotification(BluetoothCharacteristic characteristic) async {
    await characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      print('Notification value: $value');
    });
  }

  // Read MTU and request larger size
  void manageMTU() async {
    if (_connectedDevice == null) return;
    int mtu = await _connectedDevice!.mtu.first;
    print('Current MTU: $mtu');
    await _connectedDevice!.requestMtu(512);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth App'),
        actions: [
          _connectedDevice != null
              ? IconButton(
            icon: Icon(Icons.bluetooth_disabled),
            onPressed: disconnectFromDevice,
          )
              : SizedBox.shrink(),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: startScan,
            child: Text('Start Scan'),
          ),
          Expanded(
            child: _connectedDevice != null
                ? buildConnectedDeviceView()
                : Center(child: Text('No device connected')),
          ),
        ],
      ),
    );
  }

  Widget buildConnectedDeviceView() {
    return ListView.builder(
      itemCount: _services.length,
      itemBuilder: (context, index) {
        BluetoothService service = _services[index];
        return ExpansionTile(
          title: Text('Service: ${service.uuid}'),
          children: service.characteristics.map((characteristic) {
            return ListTile(
              title: Text('Characteristic: ${characteristic.uuid}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => readCharacteristic(characteristic),
                    child: Text('Read'),
                  ),
                  ElevatedButton(
                    onPressed: () => writeCharacteristic(characteristic, [0x12, 0x34]),
                    child: Text('Write'),
                  ),
                  ElevatedButton(
                    onPressed: () => setNotification(characteristic),
                    child: Text('Set Notification'),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
