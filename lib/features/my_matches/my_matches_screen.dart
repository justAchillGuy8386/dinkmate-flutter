import 'package:flutter/material.dart';
import '../../core/api/auth_service.dart';
import '../../core/api/match_service.dart';
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
    _myUserId = AuthService.currentUser?['id'] ?? "";
    setState(() {
      _matchesFuture = MatchService.getMyMatches(_myUserId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trận Đấu Của Tôi', style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: RefreshIndicator(
          color: Colors.green,
          onRefresh: () async {
            _loadMatches();
          },
          child: FutureBuilder<List<dynamic>>(
            future: _matchesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.green));
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
                      Icon(Icons.sports_tennis, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text("Bạn chưa có kèo đấu nào", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  final String matchId = match['id'] ?? "";
                  final String status = match['status'] ?? "";
                  final String oppName = match['opponent_name'] ?? "Ẩn danh";
                  final int oppElo = match['opponent_elo'] ?? 0;
                  final String oppId = match['opponent_id'] ?? "";
                  final String oppAvatar = match['opponent_avatar'] ?? "https://ui-avatars.com/api/?name=${oppName.replaceAll(' ', '+')}&background=random";

                  // Xử lý UI theo trạng thái trận đấu
                  Color statusColor = Colors.grey;
                  String statusText = "Không rõ";

                  if (status == 'Pending') {
                    statusColor = Colors.orange;
                    statusText = "Sắp diễn ra";
                  } else if (status == 'In_Progress') {
                    statusColor = Colors.blue;
                    statusText = "Đang thi đấu";
                  } else if (status == 'Completed') {
                    statusColor = Colors.green;
                    statusText = "Đã hoàn thành";
                  } else if (status == 'Disputed') {
                    statusColor = Colors.red;
                    statusText = "Đang tranh chấp";
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        if (status != 'Completed') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchDetailScreen(
                                matchId: matchId,
                                currentUserId: _myUserId,
                                opponentId: oppId,
                                opponentName: oppName,
                                opponentElo: oppElo,
                              ),
                            ),
                          ).then((_) => _loadMatches()); // Refresh lại danh sách khi quay về
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Mã: ${matchId.length > 8 ? matchId.substring(0, 8) : matchId}...", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                )
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                CircleAvatar(radius: 25, backgroundImage: NetworkImage(oppAvatar)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Đối thủ:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      Text(oppName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.workspace_premium, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text("$oppElo ELO", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                if (status != 'Completed')
                                  const Icon(Icons.chevron_right, color: Colors.grey)
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
      ),
    );
  }
}