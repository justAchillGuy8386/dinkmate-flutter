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

  factory MatchRequest.fromJson(Map<String, dynamic> json) {
    return MatchRequest(
      id: json['id'],
      creatorName: json['user']['full_name'],
      creatorElo: json['user']['elo_rating'],
      courtName: json['court_name'] ?? 'Sân chưa xác định',
      startTime: DateTime.parse(json['start_time']),
    );
  }
}