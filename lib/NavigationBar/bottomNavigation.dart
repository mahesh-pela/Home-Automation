import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_automation/Screens/DeviceConnectedScreen.dart';
import 'package:home_automation/Screens/doorLockLogs.dart';
import 'package:home_automation/Screens/homeScreen.dart';
import 'package:home_automation/Screens/logScreen.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    DeviceConnectedScreen(),
    LogScreen(),
    Doorlocklogs()
  ];

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _widgetOptions[_selectedIndex],
        ),
          BottomNavigationBar(
            items: <BottomNavigationBarItem> [
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.home),
                  label: 'Device'
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.event_note),
                  label: 'Appliances Logs',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.event_note),
                  label: 'Door Logs',
              ),
              // BottomNavigationBarItem(
              //     icon: Icon(CupertinoIcons.profile_circled),
              //     label: 'Profile'
              // )
            ],
            onTap: _onItemTapped,
            currentIndex: _selectedIndex,
          ),
      ],


    );

  }
}
