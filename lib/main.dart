import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/dashboard/dashboard_screen.dart';
import 'features/received/received_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('received_data');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Pulse',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      routes: {
        '/': (context) => const DashboardScreen(),
        '/received': (context) => const ReceivedScreen(),
      },

      initialRoute: '/',
    );
  }
}