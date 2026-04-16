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
                      Text('ELO: ${match.creatorElo} '),
                      Text('Sân: ${match.courtName}'),
                      const SizedBox(height: 4),
                      Text('Bắt đầu: ${match.startTime.hour}:${match.startTime.minute}', style: const TextStyle(color: Colors.blue)),
                    ],
                  ),
                  trailing: ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Check-in'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      // Mở Camera quét QR
                      final qrResult = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                      );

                      // Nếu quét có kết quả, gọi API gửi lên Server
                      if (qrResult != null) {
                        try {
                          // Bắn thông báo đang xử lý
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đang xác thực mã QR...')),
                          );

                          // Gọi API Check-in
                          await MatchService.checkIn(
                              match.id,
                              "249629d4-6cd8-4403-8607-17bb70766347", // Ở bản hoàn thiện, ta sẽ lấy ID thực tế của user đang đăng nhập
                              qrResult.toString()
                          );

                          // Báo thành công
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Check-in thành công! Chúc bạn chơi vui vẻ.'), backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                          // Báo lỗi nếu quét sai sân hoặc Server từ chối
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                            );
                          }
                        }
                      }
                    },
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