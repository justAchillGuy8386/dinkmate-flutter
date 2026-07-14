import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_config.dart';
import '../match_detail//dispute_screen.dart';

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
        const SnackBar(content: Text("Vui lòng chọn người chiến thắng!"), backgroundColor: Colors.amber),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. GỌI TRỰC TIẾP API NEXT.JS TẠI ĐÂY
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
        final String status = data['status']; // 'Waiting', 'Completed', hoặc 'Disputed'

        // 🟢 TRƯỜNG HỢP 1: TRẬN ĐẤU KẾT THÚC ĐẸP
        if (status == 'Completed') {
          _showDialogMessage(
            icon: Icons.stars,
            iconColor: Colors.green,
            title: "🎉 Trận đấu hoàn tất!",
            message: "Điểm số khớp nhau. Điểm ELO của bạn và đối thủ đã được cập nhật dựa trên phân tích của AI.",
            btnColor: Colors.green,
          );
        }
        // 🟡 TRƯỜNG HỢP 2: BẠN LÀ NGƯỜI NỘP TRƯỚC -> CHỜ ĐỐI THỦ
        else if (status == 'Waiting') {
          _showDialogMessage(
            icon: Icons.access_time_filled,
            iconColor: Colors.orange,
            title: "Đã ghi nhận điểm",
            message: "Hệ thống đang chờ đối thủ của bạn nhập điểm để đối chiếu. Trận đấu sẽ tự động hoàn tất nếu kết quả khớp nhau.",
            btnColor: Colors.orange,
          );
        }
        // 🔴 TRƯỜNG HỢP 3: LỆCH ĐIỂM -> TRANH CHẤP
        else if (status == 'Disputed') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phát hiện sai lệch điểm số! Chuyển sang màn hình khiếu nại."), backgroundColor: Colors.red),
          );
          // Đá văng sang trang Dispute
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
          SnackBar(content: Text(errorData['error'] ?? "Có lỗi xảy ra, vui lòng thử lại!"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lỗi kết nối máy chủ!"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Hàm Helper để hiển thị thông báo popup
  void _showDialogMessage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
    required Color btnColor
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Icon(icon, color: iconColor, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: btnColor),
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
      appBar: AppBar(
        title: const Text("NHẬP KẾT QUẢ TRẬN ĐẤU", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Chọn người thắng
            const Text("1. Ai là người chiến thắng?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text("Bạn")),
                    selected: _selectedWinnerId == widget.playerAId,
                    selectedColor: Colors.green.withOpacity(0.2),
                    onSelected: (val) => setState(() => _selectedWinnerId = widget.playerAId),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ChoiceChip(
                    label: Center(child: Text(widget.opponentName, overflow: TextOverflow.ellipsis)),
                    selected: _selectedWinnerId == widget.playerBId,
                    selectedColor: Colors.green.withOpacity(0.2),
                    onSelected: (val) => setState(() => _selectedWinnerId = widget.playerBId),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 2. Chọn Tỷ số set đấu
            const Text("2. Tỷ số trận đấu (Số Set thắng)?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["2-0", "2-1"].map((score) {
                return ChoiceChip(
                  label: Text(score, style: const TextStyle(fontSize: 16)),
                  selected: _selectedScore == score,
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(color: _selectedScore == score ? Colors.white : Colors.black),
                  onSelected: (val) => setState(() => _selectedScore = score),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // 3. Chọn độ kịch tính (Intensity) cho AI ngửi dữ liệu
            const Text("3. Độ khốc liệt của trận đấu?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["Low", "Medium", "High"].map((intensity) {
                return ChoiceChip(
                  label: Text(intensity),
                  selected: _selectedIntensity == intensity,
                  selectedColor: Colors.orange,
                  labelStyle: TextStyle(color: _selectedIntensity == intensity ? Colors.white : Colors.black),
                  onSelected: (val) => setState(() => _selectedIntensity = intensity),
                );
              }).toList(),
            ),

            const Spacer(),

            // Nút bấm gửi kết quả
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _handleSubmit,
                child: const Text("GỬI KẾT QUẢ TỈ SỐ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}