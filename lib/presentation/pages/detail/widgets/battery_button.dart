import 'package:flutter/material.dart';
import 'battery_channel.dart';

class BatteryButton extends StatelessWidget {
  const BatteryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final level = await BatteryChannel.getBatteryLevel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Battery level: ${level ?? "unknown"}%')),
        );
      },
      child: const Text('Get Battery Level'),
    );
  }
} 