import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthService {
  // Hàm login trả về một Map chứa dữ liệu JSON từ Server
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        // Mã hóa dữ liệu thành chuẩn JSON trước khi gửi
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      // Nếu Server Next.js trả về 200 OK
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Nếu sai mật khẩu (mã 401) hoặc lỗi khác
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['error'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng!');
    }
  }
}