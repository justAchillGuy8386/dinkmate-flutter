import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final int elo;

  const ProfileScreen({super.key, required this.userName, required this.elo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Hồ Sơ Cá Nhân', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                      'ELO: $elo',
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
                  _buildStatItem('Trận đấu', '24'),
                  _buildStatItem('Thắng', '15'),
                  _buildStatItem('Tỉ lệ', '62%'),
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