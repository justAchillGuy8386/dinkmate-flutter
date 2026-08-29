import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_config.dart';
import '../../core/theme/app_theme.dart';

class DisputeScreen extends StatefulWidget {
  final String matchId;
  final String currentUserId;

  const DisputeScreen({
    super.key,
    required this.matchId,
    required this.currentUserId,
  });

  @override
  State<DisputeScreen> createState() => _DisputeScreenState();
}

class _DisputeScreenState extends State<DisputeScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _fakeUploadedImageUrl;

  void _pickImage() async {
    setState(() {
      _fakeUploadedImageUrl = "https://example.com/bang-diem-fake.jpg";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã tải ảnh bằng chứng lên thành công!")),
    );
  }

  void _submitEvidence() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập lý do khiếu nại!"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/disputes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'match_id': widget.matchId,
          'user_id': widget.currentUserId,
          'reason': reason,
          'proof_image_url': _fakeUploadedImageUrl ?? "",
        }),
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (response.statusCode == 200) {
          _showSuccessDialog();
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorData['error'] ?? "Lỗi hệ thống"), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi kết nối máy chủ!"), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Icon(Icons.gavel, color: AppTheme.orange, size: 60),
        content: const Text(
          "Đã gửi khiếu nại thành công!\n\nAdmin sẽ kiểm tra bằng chứng và cập nhật ELO cho người chiến thắng. Bạn có thể rời khỏi màn hình này.",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.darkSlate, height: 1.4),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("QUAY VỀ TRANG CHỦ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text("KHIẾU NẠI KẾT QUẢ"),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Hệ thống phát hiện sai lệch điểm số. Vui lòng cung cấp bằng chứng để Admin phân xử. Người khai man sẽ bị trừ Trust Score!",
                      style: TextStyle(color: Colors.redAccent, fontSize: 13, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("1. Mô tả chi tiết lý do:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkSlate)),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Ví dụ: Tôi thắng 11-9 nhưng đối thủ cố tình nhập ngược lại...",
                hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.cardBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            const Text("2. Ảnh chụp bảng điểm (Bắt buộc):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkSlate)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: _fakeUploadedImageUrl == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 44, color: AppTheme.primary),
                    SizedBox(height: 10),
                    Text("Bấm để tải ảnh bằng chứng lên", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network("https://placehold.co/600x400/png?text=Bang+Diem", fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSubmitting ? null : _submitEvidence,
                child: _isSubmitting
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
                    : const Text("GỬI BẰNG CHỨNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}