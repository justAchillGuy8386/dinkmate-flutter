import 'package:flutter/material.dart';
// import 'matchmaking_service.dart';

class RankedArenaScreen extends StatefulWidget {
  const RankedArenaScreen({super.key});
  @override
  _RankedArenaScreenState createState() => _RankedArenaScreenState();
}

class _RankedArenaScreenState extends State<RankedArenaScreen> {
  bool _isSearching = false; // Trạng thái đang tìm trận

  void _startSearching() async {
    setState(() {
      _isSearching = true;
    });

    // Gọi API sang Next.js -> Python AI
    // await MatchmakingService.findRankedMatch();

    // Giả lập thời gian chờ 3 giây
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isSearching = false;
    });

    // Chuyển sang màn hình "Đã tìm thấy trận"
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 Hệ thống AI đã tìm thấy đối thủ cân tài cân sức!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đấu Trường Xếp Hạng"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Sẵn sàng thử thách bản thân?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Hệ thống AI sẽ tìm đối thủ ngang trình độ với bạn."),
            const SizedBox(height: 40),

            // Nút bấm đổi trạng thái
            _isSearching
                ? const CircularProgressIndicator(color: Colors.deepOrange)
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _startSearching,
              child: const Text(
                "TÌM TRẬN NGAY",
                style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

            if (_isSearching) ...[
              const SizedBox(height: 20),
              const Text("Đang phân tích dữ liệu ELO...", style: TextStyle(color: Colors.grey)),
            ]
          ],
        ),
      ),
    );
  }
}