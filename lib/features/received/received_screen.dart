import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ReceivedScreen extends StatelessWidget {
  const ReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('received_data');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Received Data"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await box.clear();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All data cleared")),
              );
            },
          )
        ],
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {

          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No data received",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: box.length,
            itemBuilder: (context, index) {

              final item = box.getAt(index);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.phone_android),

                  title: Text(
                    "Device Snapshot #${index + 1}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(
                    item.toString(),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),

                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Full Data"),
                        content: SingleChildScrollView(
                          child: Text(item.toString()),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}