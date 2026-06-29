import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../utils/models.dart';

class MatchService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static Future<List<MatchRequest>> getAvailableMatches() async {
    final response = await http.get(Uri.parse(ApiConfig.matchRequests));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((item) => MatchRequest.fromJson(item)).toList();
    } else {
      throw Exception('Không thể lấy danh sách kèo');
    }
  }

  static Future<void> checkIn(String matchId, String playerId, String qrCode) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/matches/check-in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'match_id': matchId,
        'player_id': playerId,
        'scanned_qr_code': qrCode,
      }),
    );

    print("Dữ liệu thô từ Server: ${response.body}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Check-in thất bại!');
    }
  }

  static Future<void> findRankedMatch() async {
    try {
      print("Đang gửi yêu cầu tìm trận xếp hạng lên hệ thống...");

      final response = await http.post(
        Uri.parse('$baseUrl/ai-matchmake'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Nếu AI chưa tìm đủ người
        if (data['message'] != null && data['message'].contains('Chưa đủ')) {
          print("Hệ thống báo: ${data['message']}");
          return;
        }

        // Nếu AI đã chốt kèo thành công!
        print("🎉 Trận đấu đã được tạo thành công!");
        print("Match ID: ${data['match_id']}");
        print("Cặp đấu: ${data['players']}");
        print("Độ tự tin của AI: ${data['confidence']}");

        // Chuyển hướng người dùng sang màn hình "Chi tiết Kèo đấu" để ra sân quét QR

      } else {
        print("Lỗi từ server: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối mạng: $e");
    }
  }

  static Future<bool> submitMatchScore({
    required String matchId,
    required String winnerId,
    required String scoresData,
    required String intensityFeedback,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/matches/submit-score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'match_id': matchId,
          'winner_id': winnerId,
          'scores_data': scoresData,
          'intensity_feedback': intensityFeedback,
        }),
      );

      if (response.statusCode == 200) {
        print("Cập nhật ELO thành công từ Server!");
        return true;
      } else {
        final data = jsonDecode(response.body);
        print("Lỗi từ server: ${data['error']}");
        return false;
      }
    } catch (e) {
      print("Lỗi kết nối mạng khi submit score: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>?> requestMatch(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/match-requests/find'), // API tạo yêu cầu ghép trận
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'player_id': userId, 'is_ranked': true}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['match']; // Trả về thông tin trận đấu (gồm ID và Đối thủ)
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getMyMatches(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/matches/my-matches?userId=$userId'),
      );
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return decodedData['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Lỗi kéo danh sách trận đấu: $e");
      return [];
    }
  }
}