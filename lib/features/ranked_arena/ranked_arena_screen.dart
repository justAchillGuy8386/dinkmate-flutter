import 'dart:async'; 
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_config.dart';
import '../../core/api/auth_service.dart';
import '../match_detail/match_detail_screen.dart';

class RankedArenaScreen extends StatefulWidget {
  const RankedArenaScreen({super.key});

  @override
  State<RankedArenaScreen> createState() => _RankedArenaScreenState();
}

class _RankedArenaScreenState extends State<RankedArenaScreen> with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late AnimationController _pulseController;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pollingTimer?.cancel(); //
    super.dispose();
  }

  void _startSearching() async {
    final String myUserId = AuthService.currentUser?['id'] ?? "";
    if (myUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập lại!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSearching = true);
    _pulseController.repeat();

    // 1. Tạo Phiếu tìm trận (Tới API hiện tại của bạn)
    final bool requestSuccess = await _submitMatchRequest(myUserId);

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      if (requestSuccess) {
        // 2. KÍCH HOẠT ĐỒNG HỒ TỰ ĐỘNG HỎI AI
        _startPolling(myUserId);
        _showBackgroundSearchDialog();
      } else {
        setState(() => _isSearching = false);
        _pulseController.stop();
        _pulseController.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi hệ thống! Không thể tạo yêu cầu."), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool> _submitMatchRequest(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/match-requests'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'creator_id': userId,
          'court_id': "123456789",
          'scheduled_time': DateTime.now().toIso8601String(),
          'is_ranked': true
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // QUÉT LIÊN TỤC 5 GIÂY / LẦN
  void _startPolling(String userId) {
    _pollingTimer?.cancel(); // Hủy cái cũ nếu có
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/match-requests/check-status?user_id=$userId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['status'] == 'Matched') {
            timer.cancel(); // Tắt đồng hồ ngay lập tức

            if (mounted) {
              setState(() {
                _isSearching = false;
                _pulseController.stop();
              });

              // Tắt cái Popup "Đang tìm ngầm" (nếu nó đang mở)
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }

              // Rung thông báo và CHUYỂN THẲNG VÀO TRẬN ĐẤU
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🎉 ĐÃ TÌM THẤY ĐỐI THỦ!"), backgroundColor: Colors.green),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailScreen(
                    matchId: data['match_id'],
                    currentUserId: userId,
                    opponentId: data['opponent_id'],
                    opponentName: data['opponent_name'],
                    opponentElo: data['opponent_elo'],
                    initialStatus: 'Pending',
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint("Lỗi Polling: $e");
      }
    });
  }

  void _showBackgroundSearchDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc người dùng phải bấm ĐÃ HIỂU
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.radar, color: Colors.deepOrange, size: 60),
            SizedBox(height: 10),
            Text("ĐANG TÌM KIẾM NGẦM", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 18), textAlign: TextAlign.center,),
          ],
        ),
        content: const Text(
          "Yêu cầu ghép trận của bạn đã được đưa vào hệ thống AI.\n\nBạn có thể làm việc khác. Chúng tôi sẽ chuyển bạn vào sân ngay khi có đối thủ phù hợp!",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("ĐÃ HIỂU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildPulseWidget(double delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        double value = (_pulseController.value + delay) % 1.0;
        return Opacity(
          opacity: 1.0 - value,
          child: Transform.scale(
            scale: 1.0 + (value * 1.5),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green.withOpacity(0.5), width: 2),
                color: Colors.green.withOpacity(0.1),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final int myElo = AuthService.currentUser?['elo_rating'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đấu Xếp Hạng', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.grey[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hệ thống Matchmaking AI",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const Text(
              "Tự động tìm kiếm đối thủ ngang trình độ với bạn",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 60),

            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_isSearching) _buildPulseWidget(0.0),
                  if (_isSearching) _buildPulseWidget(0.3),
                  if (_isSearching) _buildPulseWidget(0.6),

                  GestureDetector(
                    onTap: _isSearching ? null : _startSearching,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isSearching ? 130 : 160,
                      height: _isSearching ? 130 : 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSearching ? Colors.grey[400] : Colors.deepOrange,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: _isSearching ? 0 : 20,
                            spreadRadius: _isSearching ? 0 : 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSearching ? Icons.radar : Icons.sports_tennis,
                              color: Colors.white,
                              size: _isSearching ? 40 : 50,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _isSearching ? "ĐANG TÌM..." : "TÌM TRẬN",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Text("ELO hiện tại của bạn: ", style: TextStyle(color: Colors.grey)),
                  Text("$myElo", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepOrange)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}