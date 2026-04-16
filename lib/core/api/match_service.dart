import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../utils/models.dart';

class MatchService {
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
}