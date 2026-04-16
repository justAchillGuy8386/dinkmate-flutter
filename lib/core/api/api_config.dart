class ApiConfig {
  // Dùng 10.0.2.2 thay cho localhost khi chạy máy ảo Android
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Các endpoint (đường dẫn) API của chúng ta
  static const String users = '$baseUrl/users';
  static const String matches = '$baseUrl/matches';
  static const String matchRequests = '$baseUrl/match-requests';
  static const String checkIn = '$baseUrl/matches/check-in';
}