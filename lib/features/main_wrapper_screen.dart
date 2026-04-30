import 'package:flutter/material.dart';
import 'match_feed/match_feed_screen.dart';
import 'profile/profile_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'ranked_arena/ranked_arena_screen.dart';

class MainWrapper extends StatefulWidget {
  final String userName;
  final int elo;

  const MainWrapper({super.key, required this.userName, required this.elo});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // Đặt mặc định là 0 để khi vừa đăng nhập xong sẽ nhảy ngay vào Tab Bảng Xếp Hạng
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình ứng với từng tab (Thứ tự phải khớp với BottomNavigationBarItem ở dưới)
    final List<Widget> screens = [
      const LeaderboardScreen(), // Tab 0 bảng xếp hạng
      MatchFeedScreen(userName: widget.userName, elo: widget.elo), // Tab 1: Kèo Giao lưu
      const RankedArenaScreen(), // Tab 2: Kèo Đấu Hạng
      ProfileScreen(userName: widget.userName, elo: widget.elo), // Tab 3: Hồ sơ
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        // Khi có từ 4 tab trở lên, Flutter sẽ tự bật chế độ 'shifting' làm ẩn chữ.
        //  ép về 'fixed' để giữ giao diện đứng im tĩnh lặng.
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Xếp Hạng'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: 'Giao Lưu'),
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: 'Đấu Hạng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ Sơ'),
        ],
      ),
    );
  }
}