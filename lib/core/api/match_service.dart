import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';
import '../utils/models.dart';

class MatchService {
  static Future<List<MatchRequest>> getAvailableMatches() async {
    final response = await http.get(
      Uri.parse(ApiConfig.matchRequests),
      headers: AuthService.authHeaders,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((item) => MatchRequest.fromJson(item)).toList();
    } else {
      throw Exception('Không thể lấy danh sách kèo');
    }
  }

  static Future<void> checkIn(String matchId, String playerId, String qrCode) async {
    final response = await http.post(
      Uri.parse(ApiConfig.checkIn),
      headers: AuthService.authHeaders,
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
        Uri.parse(ApiConfig.aiMatchmake),
        headers: AuthService.authHeaders,
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
        Uri.parse('${ApiConfig.matches}/submit-score'),
        headers: AuthService.authHeaders,
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
        Uri.parse(ApiConfig.matchRequests),
        headers: AuthService.authHeaders,
        body: jsonEncode({'creator_id': userId, 'is_ranked': true}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data['match'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> getMyMatches(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.matches}/my-matches?userId=$userId'),
        headers: AuthService.authHeaders,
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

  static Future<bool> acceptMatch(String requestId, String acceptorId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.matches}/accept'),
        headers: AuthService.authHeaders,
        body: jsonEncode({
          'request_id': requestId,
          'acceptor_id': acceptorId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi khi nhận kèo: $e");
      return false;
    }
  }

  static Future<bool> cancelMatchRequest({required String userId, String? requestId}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.matchRequests}/cancel'),
        headers: AuthService.authHeaders,
        body: jsonEncode({
          'user_id': userId,
          if (requestId != null) 'request_id': requestId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi khi hủy yêu cầu: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> cancelMatch({
    required String matchId,
    required String userId,
    String? reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.matches}/cancel'),
        headers: AuthService.authHeaders,
        body: jsonEncode({
          'match_id': matchId,
          'user_id': userId,
          if (reason != null) 'reason': reason,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message'] ?? 'Đã hủy trận đấu'};
      } else {
        return {'success': false, 'message': data['error'] ?? 'Không thể hủy trận'};
      }
    } catch (e) {
      print("Lỗi khi hủy trận: $e");
      return {'success': false, 'message': 'Không thể kết nối đến máy chủ'};
    }
  }
}