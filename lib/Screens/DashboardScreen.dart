// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//
// class Dashboardscreen extends StatefulWidget {
//   const Dashboardscreen({super.key});
//
//   @override
//   State<Dashboardscreen> createState() => _DashboardscreenState();
// }
//
// class _DashboardscreenState extends State<Dashboardscreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.blue,
//         title: Text(
//           'Devices',
//           style: TextStyle(fontWeight: FontWeight.w500, fontSize: 23, color: Colors.white),
//         ),
//       ),
//
//       body: ListView(
//         padding: EdgeInsets.symmetric(horizontal: 15),
//         children: [
//           RoomSection(
//               title: 'Living Room',
//               devices: [
//                 DeviceCard(icon: Icons.light, label: 'Light', subLabel: 'Living Room', onSwitchChanged: (isSwitched){ _handleSwitchChange(isSwitched);}),
//                 DeviceCard(icon: FontAwesomeIcons.fan, label: 'Fan', subLabel: 'Living Room',onSwitchChanged: _handleSwitchChange)
//               ]),
//
//           RoomSection(
//               title: 'BedRoom',
//               devices: [
//                 DeviceCard(icon: Icons.ac_unit, label: 'AC', subLabel: 'BedRoom',onSwitchChanged: _handleSwitchChange),
//                 DeviceCard(icon: CupertinoIcons.tv, label: "Smart TV", subLabel: 'Bedroom', onSwitchChanged: (isSwitched){ _handleSwitchChange(isSwitched);})
//               ]),
//
//           RoomSection(
//               title: 'Dining Room',
//               devices: [
//                 DeviceCard(icon: Icons.light, label: 'Light', subLabel: 'DiningRoom', onSwitchChanged: _handleSwitchChange),
//                 DeviceCard(icon: Icons.ac_unit, label: 'AC', subLabel: 'Dining Room', onSwitchChanged: _handleSwitchChange)
//               ])
//         ],
//       ),
//     );
//   }
// }
//
// class RoomSection extends StatelessWidget{
//   final String title;
//   final List<DeviceCard> devices;
//   RoomSection({super.key, required this.title, required this.devices});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 20,),
//         Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
//         SizedBox(height: 10,),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: devices.map((device)=>Expanded(child: device)).toList(),
//         )
//       ],
//     );
//   }}
//
//
// class DeviceCard extends StatefulWidget{
//   final IconData icon;
//   final String label;
//   final String subLabel;
//   final ValueChanged<bool> onSwitchChanged;
//
//   const DeviceCard({super.key, required this.icon, required this.label, required this.subLabel, required this.onSwitchChanged});
//   @override
//   State<DeviceCard> createState() => _DeviceCardState();
// }
//
// class _DeviceCardState extends State<DeviceCard>{
//   bool isSwitched = false;
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 5),
//       padding: EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Color(0xFFE7F0F8),
//         borderRadius: BorderRadius.circular(15)
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Icon(widget.icon, size: 40, color: Colors.black87,),
//           SizedBox(height: 10,),
//           Text(widget.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//           SizedBox(height: 10,),
//           Text(widget.subLabel, style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),),
//           SizedBox(height: 10,),
//           CupertinoSwitch(
//               value: isSwitched,
//               onChanged: (value){
//                 setState(() {
//                   isSwitched = value;
//                 });
//                 print('Switch toggled: $value');
//                 widget.onSwitchChanged(value);
//               }
//           )
//         ],
//       ),
//     );
//   }
//
// }
//
//
