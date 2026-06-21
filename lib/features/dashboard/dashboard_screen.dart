import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/platform/platform_service.dart';
import '../received/received_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? data;
  List devices = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();

    loadData();
    loadDevices();

    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadDevices();
    });

    PlatformService.setReceiveListener((receivedData) async {
      final box = Hive.box('received_data');

      await box.add(receivedData);

      print("SAVED: $receivedData");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data Received & Saved ")),
        );
      }
    });
  }

  Future<void> loadData() async {
    await PlatformService.requestPermissions();

    final result = await PlatformService.getDeviceData();

    setState(() {
      data = result;
    });
  }

  Future<void> loadDevices() async {
    final list = await PlatformService.getDevices();

    setState(() {
      devices = list;
    });
  }

  Widget buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device Pulse Dashboard"),
      ),

      body: data == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await loadData();
          await loadDevices();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            buildItem("Battery", "${data!['batteryLevel']}%"),
            buildItem("Temp", "${data!['batteryTemp']} °C"),
            buildItem("Health", "${data!['batteryHealth']}"),


            buildItem("Steps", "${data!['steps']}"),
            buildItem("Activity", "${data!['activity']}"),

            const SizedBox(height: 10),

            buildItem("WiFi SSID", "${data!['wifiSSID']}"),
            buildItem("WiFi RSSI", "${data!['wifiRSSI']}"),
            buildItem("IP Address", "${data!['ipAddress']}"),

            const SizedBox(height: 10),

            buildItem("Device Model", "${data!['deviceModel']}"),
            buildItem("Android Version", "${data!['androidVersion']}"),
            buildItem("Device Name", "${data!['deviceName']}"),

            const SizedBox(height: 10),

            buildItem("Carrier", "${data!['carrier']}"),
            buildItem("SIM State", "${data!['simState']}"),
            buildItem("Signal", "${data!['signalDbm']} dBm"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await loadDevices();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Scanning devices...")),
                );
              },
              child: const Text("Share My Pulse"),
            ),

            const SizedBox(height: 20),

            if (devices.isNotEmpty)
              const Text(
                "Nearby Devices",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),

            if (devices.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "No devices found. Make sure both devices are on same WiFi.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),

            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(devices[index]['name']),
                    subtitle: Text(devices[index]['ip']),

                    onTap: () async {
                      final myData =
                      await PlatformService.getDeviceData();

                      await PlatformService.sendToDevice(
                        index,
                        myData.toString(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Sent to ${devices[index]['name']}"),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReceivedScreen(),
                  ),
                );
              },
              child: const Text("View Received Data"),
            ),
          ],
        ),
      ),
    );
  }
}