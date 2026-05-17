import 'package:flutter/material.dart';
import '../../features/check_in/qr_scanner_screen.dart';
import '../../core/api/check_in_service.dart';

class MatchDetailScreen extends StatelessWidget {
  final String matchId;
  final String opponentName;
  final int opponentElo;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
    required this.opponentName,
    required this.opponentElo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CHI TIẾT TRẬN ĐẤU", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Phần 1: Màn hình đối đầu (VS)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, // Giữ các phần tử bám sát lề trên
              children: [
                // Người chơi (Bạn)
                Expanded(child: _buildPlayerInfo("Bạn", 1166, "https://i.pravatar.cc/150?u=me")),

                // Icon VS ở giữa
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      SizedBox(height: 25),
                      Text("VS", style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600, color: Colors.green, fontStyle: FontStyle.italic)),
                      SizedBox(height: 10),
                      Icon(Icons.flash_on, color: Colors.amber, size: 30),
                    ],
                  ),
                ),

                // Đối thủ
                Expanded(child: _buildPlayerInfo(opponentName, opponentElo, "https://i.pravatar.cc/150?u=opp")),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Phần 2: Thông tin sân và hướng dẫn
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
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

                // Nút bấm quan trọng nhất: Check-in
                const Text(
                  "Vui lòng di chuyển ra sân và quét mã QR để xác nhận sự hiện diện của bạn!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      //  Mở màn hình quét và đợi kết quả
                      final String? scannedQrCode = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const QrScannerScreen()),
                      );

                      //  Nếu người dùng có quét (không bấm nút Back)
                      if (scannedQrCode != null && context.mounted) {

                        // Hiển thị vòng xoay Loading để người dùng biết app đang xử lý
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
                        );

                        // GỌI API LÊN NEXT.JS
                        //  thay "id_nguoi_choi_cua_ban" bằng ID thật lấy từ thông tin đăng nhập
                        final result = await CheckInService.verifyQrCode(
                            matchId,
                            "b6449078-b9b8-4f5d-81a0-4d76ce411235", // độ xu xi
                            scannedQrCode
                        );

                        // Đóng vòng xoay Loading
                        if (context.mounted) Navigator.pop(context);

                        //  Xử lý kết quả trả về từ Server
                        if (result != null && result.startsWith("ERROR:")) {
                          // Báo lỗi bằng màu đỏ (VD: Sai sân, QR không hợp lệ)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.replaceAll("ERROR: ", "")), backgroundColor: Colors.red),
                          );
                        } else {
                          // Thành công!
                          if (result == 'In_Progress') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Cả 2 đã Check-in! Trận đấu BẮT ĐẦU 🚀"), backgroundColor: Colors.green),
                            );
                            // Tùy chọn: Chuyển sang màn hình Ghi Điểm (Scoreboard) ở đây
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
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(String name, int elo, String avatarUrl) {
    return SizedBox(
      width: 110, // Khóa cứng chiều rộng của khung thông tin
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.green,
            child: CircleAvatar(radius: 42, backgroundImage: NetworkImage(avatarUrl)),
          ),
          const SizedBox(height: 10),
          // Thẻ Text đã được thiết lập để tự động xuống dòng
          Text(
            name,
            textAlign: TextAlign.center, // Căn giữa văn bản
            maxLines: 2, // Cho phép tối đa 2 dòng
            overflow: TextOverflow.ellipsis, // Nếu vẫn quá dài thì cắt bằng dấu ...
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
            child: Text("$elo ELO", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}