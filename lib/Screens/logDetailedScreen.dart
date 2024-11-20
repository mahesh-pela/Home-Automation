import 'package:flutter/material.dart';

class Logdetailedscreen extends StatefulWidget {
  final String imageUrl;
  final String status;
  final String timeStamp;
  const Logdetailedscreen({super.key, required this.imageUrl, required this.status, required this.timeStamp});

  @override
  State<Logdetailedscreen> createState() => _LogdetailedscreenState();
}

class _LogdetailedscreenState extends State<Logdetailedscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Details'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'hero-${widget.imageUrl}',
                child: Image.network(widget.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace){
                  return Icon(Icons.broken_image, size: 100,);
                },
                ),
              ),
            ),
            SizedBox(height: 10,),
            Wrap(children: [
              Text('Status: ', style: textStyle(),),
              SizedBox(width: 3,),
              Text(' ${widget.status}')
            ],),
            SizedBox(height: 10,),
            Wrap(children: [
              Text('Timestamp: ', style: textStyle(),),
              SizedBox(width: 3,),
              Text('${widget.timeStamp}')
            ],)
        
          ],
        ),
      ),


    );
  }

  TextStyle textStyle() => TextStyle(fontSize: 15, fontWeight: FontWeight.bold);
}
