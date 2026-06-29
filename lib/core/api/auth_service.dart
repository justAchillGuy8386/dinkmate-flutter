import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  static Map<String, dynamic>? currentUser;

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
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

        return responseData;
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['error'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng!');
    }
  }
}