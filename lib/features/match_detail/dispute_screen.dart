import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dinkmate_flutter/core/api/api_config.dart';

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
  String? _fakeUploadedImageUrl; // giả lập link ảnh

  // Hàm giả lập tải ảnh (Thực tế sẽ dùng thư viện image_picker)
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
        const SnackBar(content: Text("Vui lòng nhập lý do khiếu nại!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Gọi API gửi bằng chứng lên Next.js
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/disputes/submit-evidence'),
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
            SnackBar(content: Text(errorData['error'] ?? "Lỗi hệ thống"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi kết nối máy chủ!"), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.gavel, color: Colors.orange, size: 60),
        content: const Text(
          "Đã gửi khiếu nại thành công!\n\nAdmin sẽ kiểm tra bằng chứng và cập nhật ELO cho người chiến thắng. Bạn có thể rời khỏi màn hình này.",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () {
                // Đẩy người dùng về thẳng trang chủ (MainWrapper)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("QUAY VỀ TRANG CHỦ", style: TextStyle(color: Colors.white)),
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
        title: const Text("KHIẾU NẠI KẾT QUẢ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Hệ thống phát hiện sai lệch điểm số. Vui lòng cung cấp bằng chứng để Admin phân xử. Người khai man sẽ bị trừ Trust Score!",
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text("1. Mô tả chi tiết:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Ví dụ: Tôi thắng 11-9 nhưng đối thủ cố tình nhập ngược lại...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            const Text("2. Ảnh chụp bảng điểm (Bắt buộc):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                ),
                child: _fakeUploadedImageUrl == null
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Bấm để tải ảnh lên", style: TextStyle(color: Colors.grey)),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network("https://placehold.co/600x400/png?text=Bang+Diem", fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _isSubmitting ? null : _submitEvidence,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("GỬI BẰNG CHỨNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}