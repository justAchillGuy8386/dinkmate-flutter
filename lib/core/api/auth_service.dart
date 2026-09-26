import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  static Map<String, dynamic>? currentUser;
  static String? token;

  /// Headers chuẩn kèm JWT Token cho tất cả các HTTP Request
  static Map<String, String> get authHeaders => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        print("LOG LOGIN: $responseData");

        AuthService.currentUser = responseData['data'] ?? responseData['user'] ?? responseData;
        AuthService.token = responseData['token'];

        return responseData;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['error'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng!');
    }
  }

  static void logout() {
    currentUser = null;
    token = null;
  }
}