import 'package:flutter/material.dart';
import '../../core/api/match_service.dart';
import '../../core/utils/models.dart';
import '../check_in/qr_scanner_screen.dart';

class MatchFeedScreen extends StatelessWidget {
  final String userName;
  final int elo;

  const MatchFeedScreen({super.key, required this.userName, required this.elo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kèo Đấu Đang Chờ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              // Mở màn hình Camera và chờ kết quả trả về
              final qrResult = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScannerScreen()),
              );

              // Nếu có kết quả quét, in thử ra xem
              if (qrResult != null) {
                print("Mã QR thu được từ Camera: $qrResult");
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MatchRequest>>(
        future: MatchService.getAvailableMatches(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final matches = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(Icons.person, color: Colors.green),
                  ),
                  title: Text(match.creatorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ELO: ${match.creatorElo} • ${match.courtName}'),
                      const SizedBox(height: 4),
                      Text('Bắt đầu: ${match.startTime.hour}:${match.startTime.minute}', style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () { /* Code tham gia kèo */ },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    child: const Text('Vào kèo'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}