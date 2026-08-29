import 'package:flutter/material.dart';
import '../../core/api/auth_service.dart';
import '../../core/api/match_service.dart';
import '../../core/theme/app_theme.dart';
import '../match_detail/match_detail_screen.dart';

class MyMatchesScreen extends StatefulWidget {
  const MyMatchesScreen({super.key});

  @override
  State<MyMatchesScreen> createState() => _MyMatchesScreenState();
}

class _MyMatchesScreenState extends State<MyMatchesScreen> {
  late Future<List<dynamic>> _matchesFuture;
  String _myUserId = "";

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  void _loadMatches() {
    _myUserId = AuthService.currentUser?['id']?.toString() ?? "";
    setState(() {
      _matchesFuture = MatchService.getMyMatches(_myUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('TRẬN ĐẤU CỦA TÔI'),
      ),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () async {
          _loadMatches();
        },
        child: FutureBuilder<List<dynamic>>(
          future: _matchesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            if (snapshot.hasError || _myUserId.isEmpty) {
              return const Center(child: Text("Có lỗi hoặc chưa đăng nhập. Vui lòng thử lại!"));
            }

            final matches = snapshot.data ?? [];
            if (matches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sports_tennis, size: 64, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Bạn chưa tham gia trận đấu nào",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.darkSlate),
                    ),
                    const SizedBox(height: 6),
                    const Text("Hãy ra Bảng tin hoặc Đấu hạng để tạo kèo nhé!", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final String matchId = match['id']?.toString() ?? "";
                final String status = match['status']?.toString() ?? "";
                final String oppName = match['opponent_name']?.toString() ?? "Ẩn danh";
                final int oppElo = match['opponent_elo'] is int
                    ? match['opponent_elo']
                    : (int.tryParse(match['opponent_elo']?.toString() ?? '0') ?? 0);
                final String oppId = match['opponent_id']?.toString() ?? "";
                final String oppAvatar = match['opponent_avatar']?.toString() ??
                    "https://ui-avatars.com/api/?name=${oppName.replaceAll(' ', '+')}&background=random";

                final String playerAId = match['player_a_id']?.toString() ?? "";
                final String playerBId = match['player_b_id']?.toString() ?? "";
                final int eloChangeA = match['elo_change_a'] is int
                    ? match['elo_change_a']
                    : (int.tryParse(match['elo_change_a']?.toString() ?? '0') ?? 0);
                final int eloChangeB = match['elo_change_b'] is int
                    ? match['elo_change_b']
                    : (int.tryParse(match['elo_change_b']?.toString() ?? '0') ?? 0);

                String winnerId = (match['winner_id'] ?? match['winnerId'])?.toString() ?? "";
                if (winnerId.isEmpty) {
                  if (eloChangeA > 0) winnerId = playerAId;
                  else if (eloChangeB > 0) winnerId = playerBId;
                }

                final bool isCompleted = status == 'Completed';

                bool isWinner = false;
                if (isCompleted) {
                  if (match['is_winner'] != null) {
                    isWinner = match['is_winner'] == true;
                  } else if (winnerId.isNotEmpty) {
                    isWinner = (winnerId == _myUserId);
                  } else {
                    if (_myUserId == playerAId) {
                      isWinner = eloChangeA > 0;
                    } else if (_myUserId == playerBId) {
                      isWinner = eloChangeB > 0;
                    }
                  }
                }

                final String scoresData = (match['scores_data'] ?? match['scoresData'])?.toString() ?? "2-0";
                
                int eloChange = 0;
                if (match['elo_change'] != null) {
                  eloChange = match['elo_change'] is int
                      ? match['elo_change']
                      : (int.tryParse(match['elo_change']?.toString() ?? '0') ?? 0);
                } else {
                  if (_myUserId == playerAId) {
                    eloChange = eloChangeA.abs();
                  } else if (_myUserId == playerBId) {
                    eloChange = eloChangeB.abs();
                  }
                }

                final bool isRanked = match['is_ranked'] == true || match['isRanked'] == true;
                final String intensity = (match['intensity'] ?? match['intensity_feedback'])?.toString() ?? "Medium";

                Color statusColor = Colors.grey;
                String statusText = "Không rõ";
                Color borderColor = AppTheme.cardBorder;

                if (status == 'Pending') {
                  statusColor = AppTheme.orange;
                  statusText = "Sắp diễn ra";
                  borderColor = AppTheme.cardBorder;
                } else if (status == 'In_Progress') {
                  statusColor = Colors.blue;
                  statusText = "Đang thi đấu";
                  borderColor = Colors.blue.withOpacity(0.4);
                } else if (status == 'Waiting_For_Opponent') {
                  statusColor = Colors.indigo;
                  statusText = "Chờ đối thủ nộp điểm";
                  borderColor = Colors.indigo.withOpacity(0.4);
                } else if (isCompleted) {
                  if (isWinner) {
                    statusColor = AppTheme.primary;
                    statusText = "🏆 Chiến thắng";
                    borderColor = AppTheme.primary;
                  } else {
                    statusColor = Colors.redAccent;
                    statusText = "💔 Thất bại";
                    borderColor = Colors.redAccent;
                  }
                } else if (status == 'Disputed') {
                  statusColor = Colors.redAccent;
                  statusText = "Đang tranh chấp";
                  borderColor = Colors.redAccent;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: borderColor,
                      width: isCompleted ? 1.8 : 1.0,
                    ),
                    boxShadow: isCompleted && isWinner
                        ? AppTheme.glowShadow(AppTheme.primary.withOpacity(0.15))
                        : AppTheme.cardShadow,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchDetailScreen(
                            matchId: matchId,
                            currentUserId: _myUserId,
                            opponentId: oppId,
                            opponentName: oppName,
                            opponentElo: oppElo,
                            initialStatus: status,
                            winnerId: winnerId,
                            scoresData: scoresData,
                            eloChange: eloChange,
                            isRanked: isRanked,
                            intensity: intensity,
                          ),
                        ),
                      ).then((_) => _loadMatches());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Mã: #${matchId.length > 8 ? matchId.substring(0, 8) : matchId}",
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isRanked ? AppTheme.orange.withOpacity(0.12) : Colors.grey.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isRanked ? "Xếp Hạng" : "Giao Lưu",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isRanked ? AppTheme.orange : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              )
                            ],
                          ),
                          const Divider(height: 24, color: AppTheme.cardBorder),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(oppAvatar),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Đối thủ:", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                                    Text(
                                      oppName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkSlate),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(Icons.workspace_premium, color: Color(0xFFF59E0B), size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          "$oppElo ELO",
                                          style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                        if (isCompleted) ...[
                                          const SizedBox(width: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isRanked
                                                  ? (isWinner ? AppTheme.primary.withOpacity(0.1) : Colors.red.withOpacity(0.1))
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              isRanked
                                                  ? (isWinner ? "+$eloChange ELO" : "-$eloChange ELO")
                                                  : "Không ELO",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isRanked
                                                    ? (isWinner ? AppTheme.primary : Colors.redAccent)
                                                    : Colors.grey,
                                              ),
                                            ),
                                          )
                                        ],
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}