import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home_automation/constants/color.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:porcupine_flutter/porcupine_manager.dart';
import 'BluetoothListScreen.dart';

class DeviceConnectedScreen extends StatefulWidget {
  final BluetoothDevice? device;

  const DeviceConnectedScreen({super.key, this.device});

  @override
  _DeviceConnectedScreenState createState() => _DeviceConnectedScreenState();
}

class _DeviceConnectedScreenState extends State<DeviceConnectedScreen> {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Access the BluetoothDevice Object if provided
  BluetoothDevice? get device => widget.device;
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  PorcupineManager? _porcupineManager;
  bool _isListening = false;
  String _command = '';

  //central state for changing the state of the switch on both voice and manual control
  bool isLivingRoomLightOn = false;
  bool isBedroomLightOn = false;

  void _logDeviceState(String room, String device, bool isOn) async{
    try{
      await _firebaseFirestore.collection('device_logs').add({
        'room': room,
        'device': device,
        'state' : isOn ? 'on' : 'off',
        'timestamp': FieldValue.serverTimestamp(),

        // 'device_id': device?.id ?? 'unknown',
      });
      print('Firebase initialized successfully');
      print('Logged $device in $room as ${isOn ? 'on' :'off'}');
    }catch(e){
      print('Error initializing Firebase: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
    _initializePorcupine();
  }

  void _initializePorcupine() async {
    try {
      final String accessKey = "+4XZgMd8+n/IkEaUMf/Cq0ioWixr3rlIu7uTrhS8CvsVyJXjAcm44Q==";

      // Check and request microphone permission
      if (await Permission.microphone.request().isGranted) {
        // Load the wake word model from the assets
        _porcupineManager = await PorcupineManager.fromKeywordPaths(
          accessKey, // Access key
          ['assets/hey-lyra_en_android_v3_0_0.ppn'], // Path to your wake word model in the assets folder
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

  void _speak(String text) async{
    await _flutterTts.speak(text);
  }

  void _onWakeWordDetected(int keywordIndex) {
    print('Wake word detected!');
    _speak("Hello Chief, how can i help you?"); //speak the greeting
    _listen(); // Start listening after wake word is detected
  }

  void _listen() async {
    // Stop Porcupine to free up the microphone for speech recognition
    await _porcupineManager?.stop();

    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'notListening') {
            setState(() => _isListening = false); // Stop animating when not listening
            _restartPorcupine();  // Restart Porcupine after speech recognition ends
          }
        },
        onError: (val) {
          print('onError: $val');
          setState(() => _isListening = false); // Stop animating on error
          _restartPorcupine();
        },
      );
      if (available) {
        setState(() => _isListening = true); // Start animating when listening
        _speech.listen(onResult: (val) {
          setState(() {
            _command = val.recognizedWords.toLowerCase();
            print('Command recognized: $_command');

            //detect and control the living room light
            if (_command.contains('turn on living room light')) {
               _speak("turning on living room light");
              _handleLivingRoomLight(true); // Turn on the LED
            } else if (_command.contains('turn off living room light')) {
              _speak("turning off living room light");
              _handleLivingRoomLight(false); // Turn off the LED
            }

            //detect and control bedroom light
            else if(_command.contains('turn on bedroom light')){
              _speak("turning on bedroom light");
              _handleBedroomLight(true);
            }
            else if(_command.contains('turn off bedroom light')){
              _speak("turning off bedroom light");
              _handleBedroomLight(false);
            }
            else if(_command.contains('turn on light')){
              _speak("turning on light");
              _handleLivingRoomLight(true);
              _handleBedroomLight(true);
            }
            else if(_command.contains('turn off light')){
              _speak("turning off light");
              _handleBedroomLight(false);
              _handleLivingRoomLight(false);
            }
          });

          // After processing the command, reset the _command to an empty string
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              _command = ''; // Clear the command after 2 seconds
            });
          });
        });
      }
    } else {
      setState(() => _isListening = false); // Stop animating when stopped
      _speech.stop();
      _restartPorcupine();
    }
  }

  void _restartPorcupine() async {
    try {
      await _porcupineManager?.start();
      print('Porcupine restarted Successfully');
    } catch (e) {
      print('Error restarting Porcupine: $e');
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

  ///------- custom functions for controlling the devices for the rooms ------------///
  void _handleLivingRoomLight(bool isSwitched) {
    setState(() {
      isLivingRoomLightOn = isSwitched;
    });
    // Send the message to Bluetooth device when switch is toggled
    _sendMessageToBluetooth(isSwitched ?'1': '0');

    //log the state change to firestore
    _logDeviceState('Living Room', 'Light', isSwitched);
  }

  void _handleLivingRoomFan(bool isSwitched){}
  void _handleBedroomAC(bool isSwitched){}
  void _handleBedroomLight(bool isSwitched){
    setState(() {
      isBedroomLightOn = isSwitched;
    });
    _sendMessageToBluetooth(isSwitched ? '3': '2');

    //log the state change to Firestore
    _logDeviceState('Bedroom', 'Light', isSwitched);

  }
  void _handleDiningRoomSmartTV(bool isSwitched){}
  void _handleDiningRoomAC(bool isSwitched){}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        duration: Duration(milliseconds: 2000),
        glowColor: bgColor,
        repeat: true,
        child: GestureDetector(
          onTap: _listen,
          child: CircleAvatar(
            backgroundColor: bgColor,
            radius: 35,
            child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.white),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        // title: Text('Devices', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 23, color: Colors.white)),
        title: Text('Devices',style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BluetoothListScreen()));
            },
              ///---- showing the bluetooth icon based on the connection status------///
            icon: Icon(globalConnection != null && globalConnection!.isConnected? Icons.bluetooth_connected : Icons.bluetooth, color: Colors.white,))
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15),
        children: [
          RoomSection(
            title: 'Living Room',
            devices: [
              DeviceCard(icon: Icons.light, label: 'Light', subLabel: 'Living Room', isSwitched: isLivingRoomLightOn, onSwitchChanged: _handleLivingRoomLight),
              DeviceCard(icon: FontAwesomeIcons.fan, label: 'Fan', subLabel: 'Living Room', isSwitched: false, onSwitchChanged: _handleLivingRoomFan),
            ],
          ),
          RoomSection(
            title: 'Dining Room',
            devices: [
              DeviceCard(icon: Icons.ac_unit, label: 'AC', subLabel: 'Dining Room', isSwitched : false, onSwitchChanged: _handleDiningRoomAC),
              DeviceCard(icon: CupertinoIcons.tv, label: "Smart TV", subLabel: 'Dining Room', isSwitched: false, onSwitchChanged: _handleDiningRoomSmartTV),
            ],
          ),
          RoomSection(
            title: 'BedRoom',
            devices: [
              DeviceCard(icon: Icons.light, label: 'Light', subLabel: 'BedRoom', isSwitched: isBedroomLightOn, onSwitchChanged: _handleBedroomLight),
              DeviceCard(icon: Icons.ac_unit, label: 'AC', subLabel: 'BedRoom', isSwitched: false, onSwitchChanged: _handleBedroomAC),
            ],
          ),
        ],
      ),
      // bottomNavigationBar: Bottomnavigation(),
    );
  }

  @override
  void dispose() {
    _porcupineManager?.stop(); // Stop Porcupine detection
    _porcupineManager?.delete(); // Free resources
    super.dispose();
  }
}


class RoomSection extends StatelessWidget {
  final String title;
  final List<DeviceCard> devices;

  RoomSection({super.key, required this.title, required this.devices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: devices.map((device) => Expanded(child: device)).toList(),
        ),
      ],
    );
  }
}

class DeviceCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final bool isSwitched;
  final ValueChanged<bool> onSwitchChanged;

  const DeviceCard({super.key, required this.icon, required this.label, required this.subLabel, required this.isSwitched, required this.onSwitchChanged});

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xFFE7F0F8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 40, color: Colors.black87),
          SizedBox(height: 10),
          Text(widget.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(widget.subLabel, style: TextStyle(fontSize: 12, color: Colors.black54)),
          SizedBox(height: 10),
          CupertinoSwitch(
              value: widget.isSwitched,
              onChanged: widget.onSwitchChanged,
            ),
        ],
      ),

    );
  }
}
