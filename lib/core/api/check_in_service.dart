import 'dart:convert';
import 'package:http/http.dart' as http;

class CheckInService {
  // đổi ip ở đây
  // - dùng máy ảo Android: 10.0.2.2
  // - cắm đt thật: IP LAN của máy tính (VD: 192.168.1.x)
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Future<String?> verifyQrCode(String matchId, String playerId, String qrCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'match_id': matchId,
          'player_id': playerId,
          'qr_code_value': qrCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Trả về trạng thái của trận đấu (Pending hoặc In_Progress)
        return data['status'];
      } else {
        // Nếu lỗi (mã QR sai, không tìm thấy trận, v.v.)
        print("Server báo lỗi: ${data['error']}");
        return "ERROR: ${data['error']}";
      }
    } catch (e) {
      print("Lỗi kết nối mạng: $e");
      return "ERROR: Không thể kết nối đến máy chủ";
    }
  }
}