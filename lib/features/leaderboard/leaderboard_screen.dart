import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Dữ liệu giả lập (Mock data)
  final List<Map<String, dynamic>> _topPlayers = [
    {"name": "Độ Sushi", "elo": 2850, "avatar": "https://i.pravatar.cc/150?u=1"},
    {"name": "Kiên Nguyễn", "elo": 2720, "avatar": "https://i.pravatar.cc/150?u=2"},
    {"name": "Mộ Xum Xuê", "elo": 2680, "avatar": "https://i.pravatar.cc/150?u=3"},
    {"name": "Bác Tôi", "elo": 2100, "avatar": "https://i.pravatar.cc/150?u=4"},
    {"name": "Lộ IP", "elo": 1950, "avatar": "https://i.pravatar.cc/150?u=5"},
    {"name": "Nộm Kim Chi", "elo": 1500, "avatar": "https://i.pravatar.cc/150?u=6"},
    {"name": "Độ Mitsubishi", "elo": 1166, "avatar": "https://i.pravatar.cc/150?u=7"},
    {"name": "Dùng Thanh Nộ", "elo": 800, "avatar": "https://i.pravatar.cc/150?u=8"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            '🏆 BẢNG XẾP HẠNG DINKMATE',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)
        ),
        backgroundColor: Colors.green, // Tone màu chủ đạo của bạn
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100], // Màu nền xám nhạt để làm nổi bật các thẻ Card
        child: Column(
          children: [
            // Khung bo góc tạo điểm nhấn ở dưới AppBar
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

            // Danh sách người chơi dạng cuộn
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: _topPlayers.length,
                itemBuilder: (context, index) {
                  final player = _topPlayers[index];

                  // Logic tạo huy chương cho Top 3
                  Widget rankIcon;
                  if (index == 0) {
                    rankIcon = const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 36); // Vàng
                  } else if (index == 1) {
                    rankIcon = const Icon(Icons.workspace_premium, color: Color(0xFFC0C0C0), size: 36); // Bạc
                  } else if (index == 2) {
                    rankIcon = const Icon(Icons.workspace_premium, color: Color(0xFFCD7F32), size: 36); // Đồng
                  } else {
                    rankIcon = Text(
                      "#${index + 1}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: index < 3 ? 4 : 1, // Top 3 thẻ sẽ đổ bóng đậm hơn
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      // Hiển thị Hạng (Số hoặc Huy chương)
                      leading: SizedBox(
                        width: 40,
                        child: Center(child: rankIcon),
                      ),
                      // Hiển thị Avatar và Tên
                      title: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(player['avatar']),
                            radius: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              player['name'],
                              style: TextStyle(
                                  fontWeight: index < 3 ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 16
                              ),
                              overflow: TextOverflow.ellipsis, // Cắt chữ nếu tên quá dài
                            ),
                          ),
                        ],
                      ),
                      // Hiển thị số điểm ELO
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${player['elo']} ELO",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}