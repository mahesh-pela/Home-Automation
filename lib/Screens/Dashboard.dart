import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //initially the switch is off
  bool isSwitched = false;
  var textValue = 'Switch is Off';

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        textValue = 'Switch is on';
      });
    } else {
      setState(() {
        isSwitched = false;
        textValue = 'Switch is Off';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bluetooth',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                ///-----------Slider---------------------
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: isSwitched,
                      onChanged: toggleSwitch,
                      activeColor: Colors.blue,
                      inactiveThumbColor: Colors.grey.shade300,
                      inactiveTrackColor: CupertinoColors.white,
                    ),
                  ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
