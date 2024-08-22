import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Dashboardscreen extends StatelessWidget {
  const Dashboardscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(15),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: List.generate(6, (index){
            return Card(
              // color: Colors.red,
              elevation: 10,
              child: Center(
                child: Text('Card ${index + 1}'),
              ),
            );
          }),
        ),
      ),
    );
  }
}
