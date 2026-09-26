import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';

class CheckInService {
  static Future<String?> verifyQrCode(String matchId, String playerId, String qrCode) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.checkIn),
        headers: AuthService.authHeaders,
        body: jsonEncode({
          'match_id': matchId,
          'player_id': playerId,
          'scanned_qr_code': qrCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Trả về trạng thái của trận đấu (Pending hoặc In_Progress)
        return data['data']['status'];
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