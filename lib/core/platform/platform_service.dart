import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PlatformService {

  static const MethodChannel _channel =
  MethodChannel('device.health.channel');

  static Future<void> requestPermissions() async {
    await Permission.location.request();
    await Permission.activityRecognition.request();
    await Permission.phone.request();
  }

  static Future<Map<String, dynamic>?> getDeviceData() async {
    try {
      final result = await _channel.invokeMethod('getDeviceData');

      print("DATA: $result");

      if (result != null) {
        return Map<String, dynamic>.from(result);
      }

      return null;
    } catch (e) {
      print("ERROR: $e");
      return null;
    }
  }

  static Future<List<String>> getDevices() async {
    try {
      final result = await _channel.invokeMethod('getDevices');

      if (result != null) {
        return List<String>.from(result);
      }

      return [];
    } catch (e) {
      print("DEVICE ERROR: $e");
      return [];
    }
  }

  static Future<void> sendData(String ip, String data) async {
    try {
      await _channel.invokeMethod('sendData', {
        "ip": ip,
        "data": data,
      });
    } catch (e) {
      print("SEND ERROR: $e");
    }
  }

  static Future<void> sendToDevice(int index, String data) async {
    try {
      await _channel.invokeMethod('sendToDevice', {
        "index": index,
        "data": data,
      });
    } catch (e) {
      print("SEND DEVICE ERROR: $e");
    }
  }

  static void setReceiveListener(Function(String) onReceive) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onDataReceived") {
        onReceive(call.arguments);
      }
    });
  }
}