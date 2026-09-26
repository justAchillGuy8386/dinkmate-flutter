class MatchRequest {
  final String id;
  final String creatorName;
  final int creatorElo;
  final String courtName;
  final DateTime startTime;

  MatchRequest({
    required this.id,
    required this.creatorName,
    required this.creatorElo,
    required this.courtName,
    required this.startTime,
  });

// Chuyển JSON từ Server thành Object MatchRequest
  factory MatchRequest.fromJson(Map<String, dynamic> json) {
    // Tách các cục dữ liệu lồng nhau
    final creatorData = json['creator'];
    final courtData = json['court'];

    return MatchRequest(
      id: json['id'] ?? '',

      // Móc dữ liệu từ trong cục creator
      creatorName: creatorData != null ? creatorData['full_name'] ?? 'Người chơi Ẩn danh' : 'Người chơi Ẩn danh',
      creatorElo: creatorData != null ? creatorData['elo_rating'] ?? 1000 : 1000,

      // Móc tên sân từ trong cục court
      courtName: courtData != null ? courtData['name'] ?? 'Sân chưa xác định' : 'Sân chưa xác định',

      //  Xử lý thời gian an toàn
      startTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'])
          : DateTime.now(),
    );
  }
}

class CourtModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? qrCodeValue;
  final double? distanceKm;

  CourtModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.qrCodeValue,
    this.distanceKm,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    return CourtModel(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Sân Pickleball',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      qrCodeValue: json['qr_code_value'],
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }
}