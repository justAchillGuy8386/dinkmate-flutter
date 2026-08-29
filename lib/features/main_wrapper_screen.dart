import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'match_feed/match_feed_screen.dart';
import 'profile/profile_screen.dart';
import 'leaderboard/leaderboard_screen.dart';
import 'ranked_arena/ranked_arena_screen.dart';

class MainWrapper extends StatefulWidget {
  final String userName;
  final int elo;
  final int initialIndex;

  const MainWrapper({
    super.key,
    required this.userName,
    required this.elo,
    this.initialIndex = 2,
  });

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const LeaderboardScreen(),
      MatchFeedScreen(userName: widget.userName, elo: widget.elo),
      const RankedArenaScreen(),
      ProfileScreen(userName: widget.userName, elo: widget.elo),
    ];

    final bool isRankedTab = _selectedIndex == 2;
    final Color activeColor = isRankedTab ? AppTheme.orange : AppTheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkSlate.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: activeColor,
              unselectedItemColor: const Color(0xFF94A3B8),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.emoji_events_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.emoji_events),
                  ),
                  label: 'Xếp Hạng',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.sports_tennis_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.sports_tennis),
                  ),
                  label: 'Giao Lưu',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.local_fire_department_outlined),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.local_fire_department),
                  ),
                  label: 'Đấu Hạng',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person_outline),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Icon(Icons.person),
                  ),
                  label: 'Hồ Sơ',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}