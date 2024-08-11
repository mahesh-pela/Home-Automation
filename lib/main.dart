import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Home Automation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _controlCharacteristic;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  void _connectToDevice() async {
    final preferences = await SharedPreferences.getInstance();
    final deviceAddress = preferences.getString('controllerAddress');

    if (deviceAddress != null) {
      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (result.device.id.toString() == deviceAddress) {
            setState(() {
              _device = result.device;
            });

            _device!.connect().then((_) async {
              List<BluetoothService> services = await _device!.discoverServices();
              for (BluetoothService service in services) {
                for (BluetoothCharacteristic characteristic in service.characteristics) {
                  if (characteristic.properties.write) {
                    _controlCharacteristic = characteristic;
                  }
                }
              }

              setState(() {
                _isConnected = true;
              });
            }).catchError((e) {
              print('Error connecting to device: $e');
            });
          }
        }
      });
    } else {
      print('No device selected');
    }
  }

  void _sendCommand(String command) async {
    if (_controlCharacteristic != null && _isConnected) {
      try {
        await _controlCharacteristic!.write(command.codeUnits);
        print('Command sent: $command');
      } catch (e) {
        print('Error sending command: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Automation'),
      ),
      body: Column(
        children: [
          Text('Connected to ${_device?.name ?? 'NA'}'),
          ElevatedButton(
            onPressed: () => _sendCommand('1'),
            child: Text('Turn Light ON'),
          ),
          ElevatedButton(
            onPressed: () => _sendCommand('L'),
            child: Text('Turn Light OFF'),
          ),
          ElevatedButton(
            onPressed: () async {
              final preferences = await SharedPreferences.getInstance();
              final deviceName = preferences.getString('controllerName');
              final deviceAddress = preferences.getString('controllerAddress');
              if (deviceName != null && deviceAddress != null) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceSelectionScreen(),
                  ),
                );
              } else {
                print('Device not connected');
              }
            },
            child: Text('Select Controller'),
          ),
        ],
      ),
    );
  }
}

class DeviceSelectionScreen extends StatefulWidget {
  @override
  _DeviceSelectionScreenState createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

  void _scanForDevices() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        setState(() {
          _devicesList.add(result.device);
        });
      }
    });
  }

  void _connectToDevice(BluetoothDevice device) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString('controllerName', device.name);
    preferences.setString('controllerAddress', device.id.toString());

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Device'),
      ),
      body: ListView.builder(
        itemCount: _devicesList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_devicesList[index].name),
            subtitle: Text(_devicesList[index].id.toString()),
            onTap: () => _connectToDevice(_devicesList[index]),
          );
        },
      ),
    );
  }
}
