import 'package:flutter/material.dart';
import '../../core/api/user_service.dart';
import '../../core/api/auth_service.dart';
import '../../core/theme/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<dynamic>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = UserService.getLeaderboard();
  }

  Future<void> _refreshData() async {
    setState(() {
      _leaderboardFuture = UserService.getLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String myUserId = AuthService.currentUser?['id'] ?? "";

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Bảng Xếp Hạng DinkMate'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppTheme.primary,
        child: FutureBuilder<List<dynamic>>(
          future: _leaderboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("Có lỗi xảy ra: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)),
                ),
              );
            }

            final topPlayers = snapshot.data ?? [];

            if (topPlayers.isEmpty) {
              return const Center(child: Text("Chưa có dữ liệu bảng xếp hạng."));
            }

            final bool hasPodium = topPlayers.length >= 3;
            final listPlayers = hasPodium ? topPlayers.sublist(3) : topPlayers;

            return ListView(
              padding: const EdgeInsets.only(bottom: 30),
              children: [
                // 1. Top 3 Podium (If available)
                if (hasPodium) _buildPodium(topPlayers, myUserId),

                const SizedBox(height: 16),

                // Subtitle Header
                if (hasPodium)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'DANH SÁCH THÀNH VIÊN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),

                // 2. Rank List (Rank 4+ or all if < 3)
                ...List.generate(listPlayers.length, (index) {
                  final actualIndex = hasPodium ? index + 3 : index;
                  final player = listPlayers[index];
                  final String name = player['full_name'] ?? 'Người chơi Ẩn danh';
                  final int elo = player['elo_rating'] ?? 0;
                  final String avatarUrl = player['avatar_url'] ??
                      "https://ui-avatars.com/api/?name=${name.replaceAll(' ', '+')}&background=random";
                  final bool isMe = player['id'] == myUserId;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFFEF3C7) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isMe ? const Color(0xFFF59E0B) : AppTheme.cardBorder,
                        width: isMe ? 1.5 : 1,
                      ),
                      boxShadow: isMe ? AppTheme.glowShadow(const Color(0xFFF59E0B)) : AppTheme.cardShadow,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            "#${actualIndex + 1}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isMe ? const Color(0xFFD97706) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(avatarUrl),
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name + (isMe ? " (Bạn)" : ""),
                                  style: TextStyle(
                                    fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 15,
                                    color: AppTheme.darkSlate,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "$elo ELO",
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPodium(List<dynamic> players, String myUserId) {
    final first = players[0];
    final second = players[1];
    final third = players[2];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2 (Silver)
          Expanded(child: _buildPodiumItem(second, 2, 100, AppTheme.silverGradient, myUserId)),
          const SizedBox(width: 8),
          // Rank 1 (Gold - Center)
          Expanded(child: _buildPodiumItem(first, 1, 130, AppTheme.goldGradient, myUserId)),
          const SizedBox(width: 8),
          // Rank 3 (Bronze)
          Expanded(child: _buildPodiumItem(third, 3, 90, AppTheme.bronzeGradient, myUserId)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(dynamic player, int rank, double height, LinearGradient badgeGradient, String myUserId) {
    final String name = player['full_name'] ?? 'Ẩn danh';
    final int elo = player['elo_rating'] ?? 0;
    final String avatarUrl = player['avatar_url'] ??
        "https://ui-avatars.com/api/?name=${name.replaceAll(' ', '+')}&background=random";
    final bool isMe = player['id'] == myUserId;

    IconData crownIcon = Icons.workspace_premium;
    if (rank == 1) crownIcon = Icons.military_tech;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar Ring with Crown
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: badgeGradient,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 34 : 26,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            Positioned(
              top: rank == 1 ? -18 : -14,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  crownIcon,
                  size: rank == 1 ? 22 : 16,
                  color: rank == 1
                      ? const Color(0xFFF59E0B)
                      : (rank == 2 ? const Color(0xFF64748B) : const Color(0xFFD97706)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Name
        Text(
          name + (isMe ? " (Bạn)" : ""),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),

        // ELO Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$elo ELO",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Pedestal Card
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              "#$rank",
              style: TextStyle(
                fontSize: rank == 1 ? 32 : 24,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
      ],
    );
  }
}