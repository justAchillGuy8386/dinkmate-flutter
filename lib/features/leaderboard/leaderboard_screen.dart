import 'package:flutter/material.dart';
import '../../core/api/user_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Biến chứa future gọi API
  late Future<List<dynamic>> _leaderboardFuture;

  @override
  void initState() {
    super.initState();
    // Gọi API ngay khi màn hình vừa mở lên
    _leaderboardFuture = UserService.getLeaderboard();
  }

  // Hàm để vuốt xuống làm mới (Pull-to-refresh)
  Future<void> _refreshData() async {
    setState(() {
      _leaderboardFuture = UserService.getLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            '🏆 BẢNG XẾP HẠNG DINKMATE',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Container(
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                color: Colors.green,
                child: FutureBuilder<List<dynamic>>(
                  future: _leaderboardFuture,
                  builder: (context, snapshot) {
                    // 1. Trạng thái Đang tải (Loading)
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.green));
                    }

                    // 2. Trạng thái Lỗi
                    if (snapshot.hasError) {
                      return Center(child: Text("Có lỗi xảy ra: ${snapshot.error}"));
                    }

                    // 3. Trạng thái Thành công
                    final topPlayers = snapshot.data ?? [];

                    if (topPlayers.isEmpty) {
                      return const Center(child: Text("Chưa có dữ liệu bảng xếp hạng."));
                    }

                    // 4. Hiển thị danh sách
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(), // Đảm bảo luôn cuộn được để Refresh
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: topPlayers.length,
                      itemBuilder: (context, index) {
                        final player = topPlayers[index];

                        // Lấy dữ liệu an toàn từ API
                        final String name = player['full_name'] ?? 'Người chơi Ẩn danh';
                        final int elo = player['elo_rating'] ?? 0;
                        // Nếu user chưa có avatar thì dùng ảnh mặc định
                        final String avatarUrl = player['avatar_url'] ?? "https://ui-avatars.com/api/?name=${name.replaceAll(' ', '+')}&background=random";

                        Widget rankIcon;
                        if (index == 0) {
                          rankIcon = const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 36);
                        } else if (index == 1) {
                          rankIcon = const Icon(Icons.workspace_premium, color: Color(0xFFC0C0C0), size: 36);
                        } else if (index == 2) {
                          rankIcon = const Icon(Icons.workspace_premium, color: Color(0xFFCD7F32), size: 36);
                        } else {
                          rankIcon = Text(
                            "#${index + 1}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                          );
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          elevation: index < 3 ? 4 : 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: SizedBox(
                              width: 40,
                              child: Center(child: rankIcon),
                            ),
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(avatarUrl),
                                  radius: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                        fontWeight: index < 3 ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 16
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "$elo ELO",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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
          ],
        ),
      ),
    );
  }
}