import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_config.dart';
import '../../core/api/auth_service.dart';

class RankedArenaScreen extends StatefulWidget {
  const RankedArenaScreen({super.key});

  @override
  State<RankedArenaScreen> createState() => _RankedArenaScreenState();
}

class _RankedArenaScreenState extends State<RankedArenaScreen> with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late AnimationController _pulseController;

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
    super.dispose();
  }

  void _startSearching() async {
    // 1. LẤY ID NGƯỜI DÙNG ĐANG ĐĂNG NHẬP
    final String myUserId = AuthService.currentUser?['id'] ?? "";
    if (myUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập lại!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSearching = true);
    _pulseController.repeat();

    // 2. GỌI API LÊN NEXT.JS ĐỂ TẠO PHIẾU TÌM TRẬN
    final bool requestSuccess = await _submitMatchRequest(myUserId);

    // 3. Hiệu ứng Radar quay 3 giây cho mượt mà (UX)
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isSearching = false);
      _pulseController.stop();
      _pulseController.reset();

      if (requestSuccess) {
        // Mở Popup thông báo chạy ngầm
        _showBackgroundSearchDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi hệ thống! Không thể tạo yêu cầu."), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Hàm phụ gửi API
  Future<bool> _submitMatchRequest(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/match-requests'), // Route API Next.js của bạn
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'creator_id': userId,
          'court_id': "123456789", // Tạm thời hardcode sân
          'scheduled_time': DateTime.now().toIso8601String(),
          'is_ranked': true
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Popup thông báo Tìm Ngầm
  void _showBackgroundSearchDialog() {
    showDialog(
      context: context,
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
          "Yêu cầu ghép trận của bạn đã được đưa vào hệ thống AI.\n\nBạn có thể thoát màn hình này. Chúng tôi sẽ thông báo ngay khi có đối thủ phù hợp!",
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
              Navigator.pop(context); // Đóng Popup
            },
            child: const Text("ĐÃ HIỂU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text('ĐẤU XẾP HẠNG', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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

            // Khu vực chứa nút bấm và hiệu ứng Radar
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

            // Hiển thị ELO động
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
                  Text("$myElo", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepOrange)), // DỮ LIỆU THẬT
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}