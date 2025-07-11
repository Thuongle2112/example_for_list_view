import 'package:flutter/services.dart';

class BatteryChannel {
  static const MethodChannel _channel = MethodChannel('com.example.battery');

  static Future<int?> getBatteryLevel() async {
    try {
      final int? result = await _channel.invokeMethod<int>('getBatteryLevel');
      return result;
    } on PlatformException catch (e) {
      print('Failed to get battery level: ${e.message}');
      return null;
    }
  }
} 