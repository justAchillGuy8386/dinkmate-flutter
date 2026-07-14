import 'package:flutter/material.dart';
import '../../features/check_in/qr_scanner_screen.dart';
import '../../features/match_detail/submit_score_screen.dart';
import 'dispute_screen.dart';
import '../../core/api/check_in_service.dart';
import '../../core/api/auth_service.dart';

class MatchDetailScreen extends StatelessWidget {
  final String matchId;
  final String currentUserId;
  final String opponentId;
  final String opponentName;
  final int opponentElo;

  final String initialStatus;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
    required this.currentUserId,
    required this.opponentId,
    required this.opponentName,
    required this.opponentElo,
    this.initialStatus = 'Pending',
  });

  @override
  Widget build(BuildContext context) {
    // Lấy ELO thật
    final int myElo = AuthService.currentUser?['elo_rating'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CHI TIẾT TRẬN ĐẤU", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: initialStatus == 'Disputed' ? Colors.red : Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Phần 1: Màn hình đối đầu (VS)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: (initialStatus == 'Disputed' ? Colors.red : Colors.green).withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPlayerInfo("Bạn", myElo, "https://ui-avatars.com/api/?name=Bạn&background=random")),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Text("VS", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600, color: initialStatus == 'Disputed' ? Colors.red : Colors.green, fontStyle: FontStyle.italic)),
                      const SizedBox(height: 10),
                      const Icon(Icons.flash_on, color: Colors.amber, size: 30),
                    ],
                  ),
                ),

                Expanded(child: _buildPlayerInfo(opponentName, opponentElo, "https://ui-avatars.com/api/?name=${opponentName.replaceAll(' ', '+')}&background=random")),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Phần 2: Nội dung thay đổi theo TRẠNG THÁI (Status)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildActionSection(context),
            ),
          )
        ],
      ),
    );
  }

  // 👉 HÀM RẼ NHÁNH GIAO DIỆN THEO TRẠNG THÁI
  Widget _buildActionSection(BuildContext context) {
    // 🔴 TRẠNG THÁI 1: TRANH CHẤP
    if (initialStatus == 'Disputed') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 80),
          const SizedBox(height: 20),
          const Text(
            "TRẬN ĐẤU ĐANG CÓ TRANH CHẤP!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 10),
          const Text(
            "Phát hiện sai lệch điểm số giữa 2 người chơi. Vui lòng cung cấp bằng chứng để Admin phân xử.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DisputeScreen(
                      matchId: matchId,
                      currentUserId: currentUserId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.gavel, color: Colors.white),
              label: const Text("XEM CHI TIẾT & GỬI BẰNG CHỨNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          )
        ],
      );
    }

    // 🔵 TRẠNG THÁI 2: ĐANG THI ĐẤU HOẶC CHỜ ĐỐI THỦ NHẬP ĐIỂM
    if (initialStatus == 'In_Progress' || initialStatus == 'Waiting_For_Opponent') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.sports_tennis, color: Colors.blue, size: 80),
          const SizedBox(height: 20),
          const Text(
            "ĐANG THI ĐẤU",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          const Text(
            "Cả 2 người chơi đã check-in thành công. Chúc bạn có một trận đấu tuyệt vời!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubmitScoreScreen(
                      matchId: matchId,
                      playerAId: currentUserId,
                      playerBId: opponentId,
                      opponentName: opponentName,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_document, color: Colors.white),
              label: const Text("NHẬP KẾT QUẢ TỈ SỐ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          )
        ],
      );
    }

    // 🟢 MẶC ĐỊNH (Pending): CHỜ CHECK-IN
    return Column(
      children: [
        const ListTile(
          leading: Icon(Icons.location_on, color: Colors.green),
          title: Text("Địa điểm thi đấu", style: TextStyle(color: Colors.grey)),
          subtitle: Text("Sân Pickleball Xa La - Sân số 89", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.timer, color: Colors.green),
          title: Text("Thời gian dự kiến", style: TextStyle(color: Colors.grey)),
          subtitle: Text("Ngay bây giờ (Cần Check-in)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
        ),
        const SizedBox(height: 40),

        const Text(
          "Vui lòng di chuyển ra sân và quét mã QR để xác nhận có mặt!",
          textAlign: TextAlign.center,
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () async {
              final String? scannedQrCode = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScannerScreen()),
              );

              if (scannedQrCode != null && context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
                );

                final result = await CheckInService.verifyQrCode(
                    matchId,
                    currentUserId,
                    scannedQrCode
                );

                if (context.mounted) Navigator.pop(context);

                if (result != null && result.startsWith("ERROR:")) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.replaceAll("ERROR: ", "")), backgroundColor: Colors.red),
                  );
                } else {
                  if (result == 'In_Progress') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cả 2 đã Check-in! Trận đấu BẮT ĐẦU 🚀"), backgroundColor: Colors.green),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmitScoreScreen(
                          matchId: matchId,
                          playerAId: currentUserId,
                          playerBId: opponentId,
                          opponentName: opponentName,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Check-in thành công! Đang chờ đối thủ..."), backgroundColor: Colors.orange),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: const Text("QUÉT QR CHECK-IN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerInfo(String name, int elo, String avatarUrl) {
    return SizedBox(
      width: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: initialStatus == 'Disputed' ? Colors.red : Colors.green,
            child: CircleAvatar(radius: 42, backgroundImage: NetworkImage(avatarUrl)),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: initialStatus == 'Disputed' ? Colors.red : Colors.green, borderRadius: BorderRadius.circular(10)),
            child: Text("$elo ELO", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}