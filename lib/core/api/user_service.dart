import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class UserService {
  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/users/$userId/stats'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể tải thống kê');
    }
  }

  static Future<List<dynamic>> getLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/users/leaderboard'));

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return decodedData['data']; // Trả về mảng danh sách người chơi
      } else {
        print("Lỗi từ server khi lấy leaderboard: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi kết nối mạng: $e");
      return [];
    }
  }
}