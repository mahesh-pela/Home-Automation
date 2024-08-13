import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_automation/Controller/bluetoothController.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<BluetoothController>(
        init: BluetoothController(),
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      "Bluetooth App",
                      style: TextStyle(
                        fontSize: 28,
                        color: CupertinoColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.scanDevices(),
                  child: Text(
                    'Scan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (controller.scanResults.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.scanResults.length,
                      itemBuilder: (context, index) {
                        final result = controller.scanResults[index];
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            title: Text(
                              result.device.name ?? 'Unnamed Device',
                              style: TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              result.device.address,
                              style: TextStyle(color: Colors.black),
                            ),
                            trailing: Text(result.rssi.toString()),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        "No Devices found",
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
