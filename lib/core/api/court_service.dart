import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'auth_service.dart';
import '../utils/models.dart';

class CourtService {
  static Future<List<CourtModel>> getCourts({double? lat, double? lng, double? radius}) async {
    try {
      String url = ApiConfig.courts;
      if (lat != null && lng != null) {
        url += '?lat=$lat&lng=$lng';
        if (radius != null) {
          url += '&radius=$radius';
        }
      }

      final response = await http.get(
        Uri.parse(url),
        headers: AuthService.authHeaders,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];
        return data.map((item) => CourtModel.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Lỗi lấy danh sách sân: $e');
      return [];
    }
  }
}
