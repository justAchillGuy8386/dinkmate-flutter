import 'package:flutter/material.dart';
import '../../core/api/match_service.dart';

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

    // Gọi API gửi lên Next.js -> Python AI
    bool success = await MatchService.submitMatchScore(
      matchId: widget.matchId,
      winnerId: _selectedWinnerId!,
      scoresData: _selectedScore,
      intensityFeedback: _selectedIntensity,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      // Hiện thông báo chúc mừng
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.stars, color: Colors.green, size: 60),
          content: const Text(
            "🎉 Đã ghi nhận kết quả!\nĐiểm ELO của bạn và đối thủ đã được cập nhật dựa trên phân tích của AI.",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Quay trở lại màn hình chính (Bảng xếp hạng)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("XÁC NHẬN", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Có lỗi xảy ra, vui lòng thử lại!"), backgroundColor: Colors.red),
      );
    }
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
                child: const Text("GỬI KẾT QUẢ & TÍNH ELO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}