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
}