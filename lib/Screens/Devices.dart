import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Devices extends StatelessWidget {
  final String roomName;
  const Devices({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(roomName),
      )
    );
  }
}
