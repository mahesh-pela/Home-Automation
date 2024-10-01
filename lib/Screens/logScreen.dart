import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<Map<String, dynamic>> deviceLogs = []; // List to store device logs

  @override
  void initState() {
    super.initState();
    fetchDeviceLogs();
  }

  Future<void> fetchDeviceLogs() async {
    // Get all documents from the 'device_logs' collection, ordered by the timestamp in descending order
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("device_logs")
        .orderBy("timestamp", descending: true)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Clear the list before adding new data
      deviceLogs.clear();

      // Iterate through all the documents in the collection
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        // Extract and parse the fields for each document
        String device = doc['device']; // e.g., Light
        String room = doc['room']; // e.g., Bedroom
        String state = doc['state']; // e.g., on
        Timestamp timestamp = doc['timestamp']; // Firebase Timestamp type

        // Convert timestamp to DateTime
        DateTime dateTime = timestamp.toDate();

        // Store the fetched data in a map, including the document ID for deletion
        deviceLogs.add({
          'device': device,
          'room': room,
          'state': state,
          'timestamp': dateTime,
          'id': doc.id, // Store the document ID for deletion
        });
      }

      // Update the UI after fetching data
      setState(() {});
    } else {
      print('No data found');
    }
  }

  // Function to format DateTime as per 24-hour format with AM/PM
  String formatTimestamp(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }

  // Function to delete a log from Firestore
  Future<void> deleteLog(String docId) async {
    await FirebaseFirestore.instance.collection("device_logs").doc(docId).delete();
    // After deleting, refresh the logs
    fetchDeviceLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
      ),
      body: deviceLogs.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loader until data is fetched
          : ListView.builder(
        itemCount: deviceLogs.length, // Set the length of the list
        itemBuilder: (context, index) {
          // Fetch the corresponding device log
          Map<String, dynamic> log = deviceLogs[index];

          return Dismissible(
            key: Key(log['id']), // Unique key for each Dismissible widget (document ID)
            direction: DismissDirection.endToStart, // Swipe from right to left
            background: Container(
              color: Colors.red, // Background color for swipe action
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white), // Icon for delete action
            ),
            onDismissed: (direction) {
              // Call deleteLog when dismissed
              deleteLog(log['id']);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${log['device']} log deleted')),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8),
              child: ListTile(
                title: Text('Device: ${log['device']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room: ${log['room']}'),
                    Text('State: ${log['state']}'),
                    Text('Time: ${formatTimestamp(log['timestamp'])}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
