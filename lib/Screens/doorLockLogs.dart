import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class Doorlocklogs extends StatefulWidget {
  const Doorlocklogs({Key? key}) : super(key: key);

  @override
  State<Doorlocklogs> createState() => _DoorlocklogsState();
}

class _DoorlocklogsState extends State<Doorlocklogs> {
  List<Map<String, dynamic>> doorLogs = [];
  bool isLoading = true;
  final dio = Dio();

  // GitHub API details
  final String owner = "mahesh-pela";
  final String repo = "github_Storage";
  final String token = "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"; // Replace with secure storage
  final String baseUrl = "https://api.github.com";

  @override
  void initState() {
    super.initState();
    fetchDoorLogs();
  }

  Future<void> fetchDoorLogs() async {
    setState(() {
      isLoading = true;
    });

    try {
      final logsUrl = "$baseUrl/repos/$owner/$repo/contents/logs";
      final headers = {
        "Authorization": "token $token",
        "Accept": "application/vnd.github.v3+json",
      };

      // Fetch list of log files
      final response = await dio.get(logsUrl, options: Options(headers: headers));

      if (response.statusCode == 200) {
        final List<dynamic> files = response.data;

        List<Map<String, dynamic>> tempLogs = [];

        for (var file in files) {
          if (file['name'].endsWith('.json')) {
            String downloadUrl = file['download_url'];

            // Fetch JSON content
            final fileResponse = await dio.get(downloadUrl);

            if (fileResponse.statusCode == 200) {
              final Map<String, dynamic> logData = json.decode(fileResponse.data);

              String imageUrl = logData['image_url'] ?? '';
              if (imageUrl.isNotEmpty) {
                // Convert GitHub URL to raw content URL
                imageUrl = imageUrl.replaceFirst(
                  "https://github.com/",
                  "https://raw.githubusercontent.com/",
                ).replaceFirst(
                  "/blob/",
                  "/",
                );
              }

              tempLogs.add({
                'status': logData['status'],
                'timestamp': DateTime.parse(logData['timestamp']),
                'image_url': imageUrl,
              });
            }
          }
        }

        // Sort logs by timestamp in descending order
        tempLogs.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

        setState(() {
          doorLogs = tempLogs;
          print('door logs: $doorLogs');
          isLoading = false;
        });
      } else {
        print("Failed to fetch logs: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching logs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTimestamp(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Door Lock Logs'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : doorLogs.isEmpty
          ? const Center(child: Text('No logs available'))
          : RefreshIndicator(
        onRefresh: fetchDoorLogs,
        child: ListView.builder(
          itemCount: doorLogs.length,
          itemBuilder: (context, index) {
            final log = doorLogs[index];

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: log['image_url'] != null &&
                    log['image_url'].isNotEmpty
                    ? Image.network(
                  log['image_url'],
                  // width: 70,
                  // height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image,
                        size: 60);
                  },
                )
                    : const Icon(Icons.broken_image, size: 60),
                title: Text('Status: ${log['status']}'),
                subtitle: Text(
                    'Time: ${formatTimestamp(log['timestamp'])}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
