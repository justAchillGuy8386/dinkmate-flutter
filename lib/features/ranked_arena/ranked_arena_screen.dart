import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_config.dart';
import '../../core/api/auth_service.dart';
import '../../core/theme/app_theme.dart';
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
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pollingTimer?.cancel();
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

    final bool requestSuccess = await _submitMatchRequest(myUserId);

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      if (requestSuccess) {
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

  void _startPolling(String userId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/match-requests/check-status?user_id=$userId'),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['status'] == 'Matched') {
            timer.cancel();

            if (mounted) {
              setState(() {
                _isSearching = false;
                _pulseController.stop();
              });

              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🎉 ĐÃ TÌM THẤY ĐỐI THỦ!"), backgroundColor: AppTheme.primary),
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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Icon(Icons.radar, color: AppTheme.orange, size: 64),
            SizedBox(height: 12),
            Text(
              "ĐANG TÌM KIẾM NGẦM",
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.orange, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Text(
          "Yêu cầu ghép trận của bạn đã được đưa vào hệ thống AI.\n\nBạn có thể tự do xem các màn hình khác. Hệ thống sẽ chuyển bạn sang sân đấu ngay khi tìm thấy đối thủ ngang tầm!",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.darkSlate, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
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
            scale: 1.0 + (value * 1.6),
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.orange.withOpacity(0.6), width: 2),
                color: AppTheme.orange.withOpacity(0.12),
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Đấu Xếp Hạng'),
        backgroundColor: AppTheme.orange,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: AppTheme.orange),
                    SizedBox(width: 6),
                    Text(
                      "AI MATCHMAKING ENGINE",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.orange,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                "Đấu Trường Xếp Hạng",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.darkSlate),
              ),
              const SizedBox(height: 8),
              const Text(
                "Hệ thống AI tự động tìm kiếm đối thủ có điểm ELO & trình độ tương đồng nhất với bạn",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 50),

              // Pulsing Radar Stack
              SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isSearching) _buildPulseWidget(0.0),
                    if (_isSearching) _buildPulseWidget(0.33),
                    if (_isSearching) _buildPulseWidget(0.66),

                    GestureDetector(
                      onTap: _isSearching ? null : _startSearching,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _isSearching ? 140 : 170,
                        height: _isSearching ? 140 : 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: _isSearching
                              ? null
                              : AppTheme.rankedGradient,
                          color: _isSearching ? Colors.grey[400] : null,
                          boxShadow: _isSearching
                              ? []
                              : AppTheme.glowShadow(AppTheme.orange),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSearching ? Icons.radar : Icons.local_fire_department,
                                color: Colors.white,
                                size: _isSearching ? 44 : 56,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isSearching ? "ĐANG TÌM..." : "TÌM TRẬN",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  letterSpacing: 0.5,
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
              const SizedBox(height: 50),

              // Current ELO Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.workspace_premium, color: Color(0xFFF59E0B), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ELO hiện tại", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        Text(
                          "$myElo ELO",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: AppTheme.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}