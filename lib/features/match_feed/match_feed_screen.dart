import 'package:flutter/material.dart';
import '../../core/api/match_service.dart';
import '../../core/utils/models.dart';
import '../check_in/qr_scanner_screen.dart';

class MatchFeedScreen extends StatefulWidget {
  final String userName;
  final int elo;

  const MatchFeedScreen({super.key, required this.userName, required this.elo});

  @override
  State<MatchFeedScreen> createState() => _MatchFeedScreenState();
}

class _MatchFeedScreenState extends State<MatchFeedScreen> {
  // Biến lưu trữ luồng dữ liệu
  late Future<List<MatchRequest>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _loadMatches(); // Tải dữ liệu ngay khi vừa mở màn hình
  }

  void _loadMatches() {
    _matchesFuture = MatchService.getAvailableMatches();
  }

  // vuốt xuống để refresh
  Future<void> _handleRefresh() async {
    setState(() {
      _loadMatches(); // Gọi lại API để lấy dữ liệu mới
    });
    // Chờ API chạy xong để tắt vòng xoay loading của RefreshIndicator
    await _matchesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kèo Đấu Đang Chờ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<MatchRequest>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final matches = snapshot.data ?? [];

          // XỬ LÝ KHI DANH SÁCH RỖNG (Vẫn bọc RefreshIndicator để vuốt được)
          if (matches.isEmpty) {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              color: Colors.green,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(), // Ép Flutter cho phép vuốt dù danh sách trống
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(
                    child: Text(
                      'Hiện chưa có kèo đấu nào.\nVuốt xuống để làm mới!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          // bọc danh sách bằng resfresh bằng refreshindicator
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Colors.green,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
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
                        Text('Bắt đầu: ${match.startTime.hour}:${match.startTime.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.blue)),
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
                        final qrResult = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                        );
                        if (qrResult != null) {
                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đang xác thực mã QR...')),
                            );
                            await MatchService.checkIn(
                                match.id,
                                "249629d4-6cd8-4403-8607-17bb70766347",
                                qrResult.toString()
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Check-in thành công! Chúc bạn chơi vui vẻ.'), backgroundColor: Colors.green),
                              );
                              // Check-in xong tự động tải lại trang để mất cái kèo đó đi
                              _handleRefresh();
                            }
                          } catch (e) {
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
            ),
          );
        },
      ),
    );
  }
}