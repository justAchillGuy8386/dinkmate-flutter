import 'package:flutter/material.dart';
import '../../core/api/user_service.dart';
import '../../core/api/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../my_matches/my_matches_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final int elo;

  const ProfileScreen({super.key, required this.userName, required this.elo});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = AuthService.currentUser?['id'] ?? "";

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Hồ Sơ Cá Nhân'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: UserService.getUserStats(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final hasData = snapshot.hasData && !snapshot.hasError;
          final currentElo = hasData ? snapshot.data!['elo'] : elo;
          final totalMatches = hasData ? snapshot.data!['total_matches'].toString() : '0';
          final wins = hasData ? snapshot.data!['wins'].toString() : '0';
          final winRate = hasData ? '${snapshot.data!['win_rate']}%' : '0%';

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 35),
            child: Column(
              children: [
                // 1. Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: const CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 56, color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Text(
                          'ELO: $currentElo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Stats Section Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildStatCard('Trận đấu', totalMatches, Icons.sports_tennis, AppTheme.primary),
                      const SizedBox(width: 12),
                      _buildStatCard('Chiến thắng', wins, Icons.emoji_events, const Color(0xFFF59E0B)),
                      const SizedBox(width: 12),
                      _buildStatCard('Tỉ lệ thắng', winRate, Icons.pie_chart, AppTheme.orange),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Menu Options Container
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cardBorder),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(context, Icons.history, 'Trận đấu của tôi'),
                        const Divider(height: 1, indent: 56, endIndent: 16, color: AppTheme.cardBorder),
                        _buildMenuItem(context, Icons.workspace_premium_outlined, 'Thành tích & Huy hiệu'),
                        const Divider(height: 1, indent: 56, endIndent: 16, color: AppTheme.cardBorder),
                        _buildMenuItem(context, Icons.settings_outlined, 'Cài đặt tài khoản'),
                        const Divider(height: 1, indent: 56, endIndent: 16, color: AppTheme.cardBorder),
                        _buildMenuItem(context, Icons.help_outline, 'Hỗ trợ & Góp ý'),
                        const Divider(height: 1, indent: 56, endIndent: 16, color: AppTheme.cardBorder),
                        _buildMenuItem(context, Icons.logout, 'Đăng xuất', isLogout: true),
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.darkSlate,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {bool isLogout = false}) {
    final Color iconColor = isLogout ? Colors.redAccent : AppTheme.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.redAccent : AppTheme.darkSlate,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
      onTap: () {
        if (isLogout) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Xác nhận đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    AuthService.currentUser = null;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
                  },
                  child: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        } else if (title == 'Trận đấu của tôi') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyMatchesScreen()),
          );
        }
      },
    );
  }
}