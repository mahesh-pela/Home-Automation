import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'BluetoothListScreen.dart';

class DeviceConnectedScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceConnectedScreen({super.key, required this.device});

  @override
  _DeviceConnectedScreenState createState() => _DeviceConnectedScreenState();
}

class _DeviceConnectedScreenState extends State<DeviceConnectedScreen> {
  late stt.SpeechToText _speech;
  PorcupineManager? _porcupineManager;
  bool _isListening = false;
  String _command = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializePorcupine();
  }

  void _initializePorcupine() async {
    try {
      final String accessKey = "RhbtYL5hH2nqlT90Dx5E7Zqx1vUFEDOV+AUZvDWZpPbF3BpYHdSThQ==";
      _porcupineManager = await PorcupineManager.fromKeywordPaths(
        accessKey, // Access key
        ['assets/hey_lyra.ppn'], // Replace with your wake word model path
        _onWakeWordDetected, // Callback when wake word is detected
        sensitivities: [0.5], // Sensitivity level (optional)
      );
      await _porcupineManager?.start(); // Start Porcupine detection
      print('Porcupine started successfully');
    } catch (e) {
      print('Porcupine initialization error: $e');
    }
  }

  void _onWakeWordDetected(int keywordIndex) {
    print('Wake word detected!');
    _listen(); // Start listening after wake word is detected
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) => setState(() {
          _command = val.recognizedWords.toLowerCase();
          print('Command recognized: $_command');
          if (_command.contains('turn on light')) {
            _sendMessageToBluetooth('1'); // Turn on the LED
          } else if (_command.contains('turn off light')) {
            _sendMessageToBluetooth('0'); // Turn off the LED
          }
        }));
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected to ${widget.device.name ?? "Unknown Device"}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _sendMessageToBluetooth('1');
                      },
                      child: Text('ON'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _sendMessageToBluetooth('0');
                      },
                      child: Text('OFF'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: _listen, // Optionally, if you still want manual control
              child: Image.asset('assets/icons/microphone.png'),
            ),
            SizedBox(height: 20),
            Text(
              _command,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _porcupineManager?.stop(); // Stop Porcupine detection
    _porcupineManager?.delete(); // Free resources
    super.dispose();
  }
}
