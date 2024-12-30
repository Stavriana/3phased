import 'package:flutter/material.dart';

class AvatarSelectionScreen extends StatelessWidget {
  final String code;

  const AvatarSelectionScreen({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avatar Setup')),
      body: Center(
        child: Text(
          'Room Code: $code', // Display room code or perform setup logic
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
