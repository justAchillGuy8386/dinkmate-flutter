import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_config.dart';
import '../../core/theme/app_theme.dart';
import '../match_detail/dispute_screen.dart';

class SubmitScoreScreen extends StatefulWidget {
  final String matchId;
  final String playerAId;
  final String playerBId;
  final String opponentName;

  const SubmitScoreScreen({
    super.key,
    required this.matchId,
    required this.playerAId,
    required this.playerBId,
    required this.opponentName,
  });

  @override
  State<SubmitScoreScreen> createState() => _SubmitScoreScreenState();
}

class _SubmitScoreScreenState extends State<SubmitScoreScreen> {
  String? _selectedWinnerId;
  String _selectedScore = "2-0";
  String _selectedIntensity = "Medium";
  bool _isLoading = false;

  void _handleSubmit() async {
    if (_selectedWinnerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Vui lòng chọn người chiến thắng!"),
          backgroundColor: Colors.amber[800],
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/matches/submit-score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'match_id': widget.matchId,
          'user_id': widget.playerAId,
          'winner_id': _selectedWinnerId,
          'scores_data': _selectedScore,
          'intensity_feedback': _selectedIntensity,
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final String status = data['status'];

        if (status == 'Completed') {
          _showDialogMessage(
            icon: Icons.stars,
            iconColor: AppTheme.primary,
            title: "🎉 Trận đấu hoàn tất!",
            message: "Điểm số khớp nhau. Điểm ELO của bạn và đối thủ đã được cập nhật dựa trên phân tích của AI.",
            btnColor: AppTheme.primary,
          );
        } else if (status == 'Waiting') {
          _showDialogMessage(
            icon: Icons.access_time_filled,
            iconColor: AppTheme.orange,
            title: "Đã ghi nhận điểm",
            message: "Hệ thống đang chờ đối thủ của bạn nhập điểm để đối chiếu. Trận đấu sẽ tự động hoàn tất nếu kết quả khớp nhau.",
            btnColor: AppTheme.orange,
          );
        } else if (status == 'Disputed') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phát hiện sai lệch điểm số! Chuyển sang màn hình khiếu nại."), backgroundColor: Colors.redAccent),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DisputeScreen(
                matchId: widget.matchId,
                currentUserId: widget.playerAId,
              ),
            ),
          );
        }
      } else if (mounted) {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? "Có lỗi xảy ra, vui lòng thử lại!"), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi kết nối máy chủ!"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showDialogMessage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required Color btnColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Icon(icon, color: iconColor, size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkSlate)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF64748B), height: 1.4)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("XÁC NHẬN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("NHẬP KẾT QUẢ TRẬN ĐẤU"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Winner Card
            _buildSectionCard(
              title: "1. Ai là người chiến thắng?",
              child: Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text("Bạn", style: TextStyle(fontWeight: FontWeight.bold))),
                      selected: _selectedWinnerId == widget.playerAId,
                      selectedColor: AppTheme.primary.withOpacity(0.2),
                      side: BorderSide(
                        color: _selectedWinnerId == widget.playerAId ? AppTheme.primary : AppTheme.cardBorder,
                      ),
                      onSelected: (val) => setState(() => _selectedWinnerId = widget.playerAId),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          widget.opponentName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      selected: _selectedWinnerId == widget.playerBId,
                      selectedColor: AppTheme.primary.withOpacity(0.2),
                      side: BorderSide(
                        color: _selectedWinnerId == widget.playerBId ? AppTheme.primary : AppTheme.cardBorder,
                      ),
                      onSelected: (val) => setState(() => _selectedWinnerId = widget.playerBId),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Score Card
            _buildSectionCard(
              title: "2. Tỷ số trận đấu (Set thắng)?",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["2-0", "2-1"].map((score) {
                  final isSelected = _selectedScore == score;
                  return ChoiceChip(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(score, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.darkSlate),
                    onSelected: (val) => setState(() => _selectedScore = score),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // 3. Intensity Card
            _buildSectionCard(
              title: "3. Độ khốc liệt của trận đấu (Cho AI)?",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["Low", "Medium", "High"].map((intensity) {
                  final isSelected = _selectedIntensity == intensity;
                  return ChoiceChip(
                    label: Text(intensity, style: const TextStyle(fontWeight: FontWeight.bold)),
                    selected: isSelected,
                    selectedColor: AppTheme.orange,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.darkSlate),
                    onSelected: (val) => setState(() => _selectedIntensity = intensity),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 36),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.glowShadow(AppTheme.primary),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _handleSubmit,
                  child: const Text(
                    "GỬI KẾT QUẢ TỈ SỐ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.darkSlate),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}