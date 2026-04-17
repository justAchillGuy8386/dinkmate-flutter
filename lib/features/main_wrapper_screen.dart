import 'package:flutter/material.dart';
import 'match_feed/match_feed_screen.dart';
import 'profile/profile_screen.dart';

class MainWrapper extends StatefulWidget {
  final String userName;
  final int elo;

  const MainWrapper({super.key, required this.userName, required this.elo});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình ứng với từng tab
    final List<Widget> screens = [
      MatchFeedScreen(userName: widget.userName, elo: widget.elo),
      ProfileScreen(userName: widget.userName, elo: widget.elo),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: 'Kèo Đấu'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ Sơ'),
        ],
      ),
    );
  }
}