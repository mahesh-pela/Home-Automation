import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:home_automation/constants/color.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
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
      final String accessKey = "Jc8x3U2volT5tY7b7miqp5j4N4T8pq6lTdhMwMCVK0SqDxe7yui32A==";

      // Check and request microphone permission
      if (await Permission.microphone.request().isGranted) {
        // Load the wake word model from the assets
        _porcupineManager = await PorcupineManager.fromKeywordPaths(
          accessKey, // Access key
          ['assets/hey_lyra.ppn'], // Path to your wake word model in the assets folder
          _onWakeWordDetected, // Callback when wake word is detected
          sensitivities: [0.5], // Sensitivity level (optional)
        );

        await _porcupineManager?.start(); // Start Porcupine detection
        print('Porcupine started successfully');
      } else {
        print('Microphone permission denied');
      }
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
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'notListening') {
            setState(() => _isListening = false); // Stop animating when not listening
          }
        },
        onError: (val) {
          print('onError: $val');
          setState(() => _isListening = false); // Stop animating on error
        },
      );
      if (available) {
        setState(() => _isListening = true); // Start animating when listening
        _speech.listen(onResult: (val) {
          setState(() {
            _command = val.recognizedWords.toLowerCase();
            print('Command recognized: $_command');
            if (_command.contains('turn on light')) {
              _sendMessageToBluetooth('1'); // Turn on the LED
            } else if (_command.contains('turn off light')) {
              _sendMessageToBluetooth('0'); // Turn off the LED
            }
          });

          // After processing the command, reset the _command to an empty string
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _command = ''; // Clear the command after 2 seconds
            });
          });
        });
      }
    } else {
      setState(() => _isListening = false); // Stop animating when stopped
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: AvatarGlow(
          animate: _isListening,
          duration: Duration(milliseconds: 2000),
          glowColor: bgColor,
          repeat: true,
          child: GestureDetector(
            onTap: _listen,
            child: CircleAvatar(
              backgroundColor: bgColor,
              radius: 35,
              child: Icon(_isListening? Icons.mic: Icons.mic_none, color: Colors.white,),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Connected to ${widget.device.name ?? "Unknown Device"}'),
      ),

      ///----------------------------///
      body: Container(
        padding: const EdgeInsets.all(20),
        margin: EdgeInsets.only(bottom: 150),
        child: Column(
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
