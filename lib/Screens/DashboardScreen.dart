import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dashboardscreen extends StatefulWidget {
  const Dashboardscreen({super.key});

  @override
  State<Dashboardscreen> createState() => _DashboardscreenState();
}

class _DashboardscreenState extends State<Dashboardscreen> {
  //empty list
  List<Widget> _cards = [];

  ///-----------this will trigger when clicked on the floating action button--------
  void addCardWithName(){
    TextEditingController txtName = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Add Room'),
            content: TextField(
              controller: txtName,
              decoration: InputDecoration(hintText: 'Enter Name'),
            ),
            
            actions: <Widget>[
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                  child: Text('Cancel')),
              
              ElevatedButton(
                  onPressed: (){
                    setState(() {
                      _cards.add(
                        Card(
                          elevation: 10,
                          child: Center(child: Text(txtName.text, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600 ),)),
                        )
                      );
                    });
                    Navigator.pop(context);
              }, child: Text('Add'))
            ],
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: _cards
        ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCardWithName,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white, size: 30,),
      ),
    );
  }
}
