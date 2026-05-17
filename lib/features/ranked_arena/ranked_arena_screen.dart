import 'package:dinkmate_flutter/features/match_detail/match_detail_screen.dart';
import 'package:flutter/material.dart';

class RankedArenaScreen extends StatefulWidget {
  const RankedArenaScreen({super.key});

  @override
  State<RankedArenaScreen> createState() => _RankedArenaScreenState();
}

// Bổ sung SingleTickerProviderStateMixin để chạy hiệu ứng Animation
class _RankedArenaScreenState extends State<RankedArenaScreen> with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo bộ đếm nhịp cho sóng Radar (1.5 giây cho 1 vòng sóng)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startSearching() async {
    setState(() {
      _isSearching = true;
    });
    _pulseController.repeat(); // Bắt đầu phát sóng Radar liên tục

    // Tạm thời giả lập AI đang tính toán mất 4 giây
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      setState(() {
        _isSearching = false;
      });
      _pulseController.stop(); // Tắt sóng Radar
      _pulseController.reset();

      _showMatchFoundDialog();
    }
  }

  void _showMatchFoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc người dùng phải tương tác
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("ĐÃ TÌM THẤY TRẬN!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
        content: const Text(
          "AI đã ghép cặp thành công.\nĐối thủ của bạn đang chờ. Hãy di chuyển ra sân để Check-in mã QR!",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push (
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchDetailScreen(
                    matchId: "id_gia_lap_1",
                    opponentName: "Tô Tổng Văn Giang Hưng Yên",
                    opponentElo: 2680,
                  ),
                ),
              );
            },
            child: const Text("XEM CHI TIẾT KÈO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Hàm vẽ từng vòng sóng Radar
  Widget _buildPulseWidget(double delay) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Tạo độ trễ cho các vòng sóng khác nhau
        double value = (_pulseController.value + delay) % 1.0;
        return Opacity(
          opacity: 1.0 - value,
          child: Transform.scale(
            scale: 1.0 + (value * 1.5), // Phóng to gấp 1.5 lần
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 ĐẤU TRƯỜNG RANK', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green,
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

            // Khu vực chứa nút bấm và hiệu ứng Radar
            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ba vòng sóng Radar với độ trễ khác nhau
                  if (_isSearching) _buildPulseWidget(0.0),
                  if (_isSearching) _buildPulseWidget(0.3),
                  if (_isSearching) _buildPulseWidget(0.6),

                  // Nút bấm trung tâm
                  GestureDetector(
                    onTap: _isSearching ? null : _startSearching,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isSearching ? 130 : 160,
                      height: _isSearching ? 130 : 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSearching ? Colors.grey[400] : Colors.green,
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

            // Thông tin mô phỏng ELO hiện tại của người chơi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: Colors.amber),
                  SizedBox(width: 8),
                  Text("ELO hiện tại của bạn: ", style: TextStyle(color: Colors.grey)),
                  Text("1166", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}