import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:home_automation/Screens/DeviceConnectedScreen.dart';
import 'package:home_automation/Screens/homeScreen.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Homescreen(),
    DeviceConnectedScreen(),
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
                  label: 'Home'
              ),
              BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.device_phone_portrait),
                  label: 'Devices'
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
