import 'package:flutter/material.dart';

class MatchFeedScreen extends StatelessWidget {
  final String userName;
  final int elo;

  const MatchFeedScreen({super.key, required this.userName, required this.elo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Tin Kèo Đấu'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            Text(
                'Xin chào, $userName!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Text(
                'ELO hiện tại của bạn: $elo',
                style: const TextStyle(fontSize: 18, color: Colors.grey)
            ),
          ],
        ),
      ),
    );
  }
}