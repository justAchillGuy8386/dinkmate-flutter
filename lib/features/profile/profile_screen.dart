import 'package:flutter/material.dart';
import '../../core/api/user_service.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final int elo; // Đây là ELO cũ từ lúc đăng nhập, ta sẽ dùng nó làm dữ liệu dự phòng (fallback)
  final String userId = "249629d4-6cd8-4403-8607-17bb70766347";

  const ProfileScreen({super.key, required this.userName, required this.elo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hồ Sơ Cá Nhân'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: UserService.getUserStats(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          // Trích xuất dữ liệu mới, nếu lỗi thì dùng tạm dữ liệu cũ
          final hasData = snapshot.hasData && !snapshot.hasError;
          final currentElo = hasData ? snapshot.data!['elo'] : elo;
          final totalMatches = hasData ? snapshot.data!['total_matches'].toString() : '0';
          final wins = hasData ? snapshot.data!['wins'].toString() : '0';
          final winRate = hasData ? '${snapshot.data!['win_rate']}%' : '0%';

          return SingleChildScrollView(
            child: Column(
              children: [
                // 1. Header Section
                Container(
                  color: Colors.green,
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 60, color: Colors.green),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        userName,
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ELO: $currentElo',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Stats Section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildStatItem('Trận đấu', totalMatches),
                      _buildStatItem('Thắng', wins),
                      _buildStatItem('Tỉ lệ', winRate),
                    ],
                  ),
                ),

                // 3. Menu Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(Icons.history, 'Lịch sử kèo đấu'),
                        const Divider(height: 1),
                        _buildMenuItem(Icons.workspace_premium, 'Thành tích & Huy hiệu'),
                        const Divider(height: 1),
                        _buildMenuItem(Icons.settings, 'Cài đặt tài khoản'),
                        const Divider(height: 1),
                        _buildMenuItem(Icons.help_outline, 'Hỗ trợ & Góp ý'),
                        const Divider(height: 1),
                        _buildMenuItem(Icons.logout, 'Đăng xuất', isLogout: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.green),
      title: Text(title, style: TextStyle(color: isLogout ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        // Xử lý sự kiện khi bấm vào menu
      },
    );
  }
}