import 'package:flutter/material.dart';
import '../../features/check_in/qr_scanner_screen.dart';
import '../../features/match_detail/submit_score_screen.dart';
import 'dispute_screen.dart';
import '../../core/api/check_in_service.dart';
import '../../core/api/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../main_wrapper_screen.dart';

class MatchDetailScreen extends StatelessWidget {
  final String matchId;
  final String currentUserId;
  final String opponentId;
  final String opponentName;
  final int opponentElo;
  final String initialStatus;
  final String? winnerId;
  final String? scoresData;
  final int? eloChange;
  final bool? isRanked;
  final String? intensity;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
    required this.currentUserId,
    required this.opponentId,
    required this.opponentName,
    required this.opponentElo,
    this.initialStatus = 'Pending',
    this.winnerId,
    this.scoresData,
    this.eloChange,
    this.isRanked,
    this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final int myElo = AuthService.currentUser?['elo_rating'] ?? 0;
    final bool isDisputed = initialStatus == 'Disputed';
    final bool isCompleted = initialStatus == 'Completed';
    final bool isWinner = isCompleted && (winnerId != null && winnerId!.isNotEmpty ? winnerId == currentUserId : true);

    Color headerColor = AppTheme.primary;
    if (isDisputed) {
      headerColor = Colors.redAccent;
    } else if (isCompleted) {
      headerColor = isWinner ? AppTheme.primary : Colors.redAccent;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isCompleted ? "Kết Quả Trận Đấu" : "Chi Tiết Trận Đấu"),
        backgroundColor: headerColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              final String myName = AuthService.currentUser?['full_name'] ?? 'Người chơi';
              final int myElo = AuthService.currentUser?['elo_rating'] ?? 0;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainWrapper(
                    userName: myName,
                    elo: myElo,
                  ),
                ),
              );
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // VS Matchup Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                gradient: isDisputed || (isCompleted && !isWinner)
                    ? const LinearGradient(colors: [Colors.redAccent, Colors.red])
                    : AppTheme.primaryGradient,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: _buildPlayerInfo("Bạn", myElo, "https://ui-avatars.com/api/?name=Bạn&background=random")),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        const Text(
                          "VS",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.flash_on, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildPlayerInfo(
                      opponentName,
                      opponentElo,
                      "https://ui-avatars.com/api/?name=${opponentName.replaceAll(' ', '+')}&background=random",
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action / Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildActionSection(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context) {
    // 🏆 TRẠNG THÁI: HOÀN THÀNH (Completed)
    if (initialStatus == 'Completed') {
      final bool isWinner = (winnerId != null && winnerId!.isNotEmpty) ? (winnerId == currentUserId) : true;
      final int deltaElo = eloChange ?? 0;
      final bool ranked = isRanked ?? false;
      final String matchType = ranked ? "Đấu Hạng AI (Ranked)" : "Giao Lưu (Casual)";
      final String scoreStr = scoresData ?? "2-0";
      final String intensityStr = intensity ?? "Medium";

      return Column(
        children: [
          // 1. Result Banner Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isWinner ? AppTheme.primary : Colors.redAccent,
                width: 1.5,
              ),
              boxShadow: isWinner
                  ? AppTheme.glowShadow(AppTheme.primary.withOpacity(0.2))
                  : AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                Icon(
                  isWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 56,
                  color: isWinner ? const Color(0xFFF59E0B) : Colors.redAccent,
                ),
                const SizedBox(height: 12),
                Text(
                  isWinner ? "KẾT QUẢ: CHIẾN THẮNG 🏆" : "KẾT QUẢ: THẤT BẠI 💔",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isWinner ? AppTheme.primary : Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Tỉ số set đấu: $scoreStr",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkSlate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. ELO Change / Casual Notice Card
          if (ranked)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isWinner ? AppTheme.primary.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isWinner ? Icons.trending_up : Icons.trending_down,
                      color: isWinner ? AppTheme.primary : Colors.redAccent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Biến động ELO (Đấu Hạng)",
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                        Text(
                          isWinner ? "+$deltaElo ELO" : "-$deltaElo ELO",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isWinner ? AppTheme.primary : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.handshake_outlined, color: AppTheme.orange, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Chế độ trận đấu", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                        Text("Trận Giao Lưu (Không tính ELO)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.darkSlate)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // 3. Match Nature Properties Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TÍNH CHẤT TRẬN ĐẤU",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 14),
                _buildDetailRow(Icons.sports_score, "Loại hình", matchType),
                const Divider(height: 20, color: AppTheme.cardBorder),
                _buildDetailRow(Icons.local_fire_department, "Cường độ trận đấu", intensityStr),
                const Divider(height: 20, color: AppTheme.cardBorder),
                _buildDetailRow(Icons.tag, "Mã trận đấu", "#${matchId.length > 8 ? matchId.substring(0, 8) : matchId}"),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Return Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkSlate,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  final String myName = AuthService.currentUser?['full_name'] ?? 'Người chơi';
                  final int myElo = AuthService.currentUser?['elo_rating'] ?? 0;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainWrapper(
                        userName: myName,
                        elo: myElo,
                      ),
                    ),
                  );
                }
              },
              child: const Text("QUAY VỀ TRANG CHỦ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    }

    // 🔴 TRẠNG THÁI: TRANH CHẤP
    if (initialStatus == 'Disputed') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              "TRẬN ĐẤU ĐANG TRANH CHẤP",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            const Text(
              "Phát hiện sai lệch điểm số giữa 2 người chơi. Vui lòng cung cấp bằng chứng để Admin phân xử.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), height: 1.4, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
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
                label: const Text(
                  "GỬI BẰNG CHỨNG PHÂN XỬ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            )
          ],
        ),
      );
    }

    // 🔵 TRẠNG THÁI: ĐANG THI ĐẤU / CHỜ ĐỐI THỦ NHẬP ĐIỂM
    if (initialStatus == 'In_Progress' || initialStatus == 'Waiting_For_Opponent') {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sports_tennis, color: AppTheme.primary, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              "TRẬN ĐẤU ĐANG XẢY RA",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.darkSlate),
            ),
            const SizedBox(height: 8),
            const Text(
              "Cả 2 người chơi đã check-in thành công. Vui lòng thi đấu và hoàn thành nộp điểm số sau trận đấu!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), height: 1.4, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.glowShadow(AppTheme.primary),
                ),
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
                  label: const Text(
                    "NHẬP KẾT QUẢ TỈ SỐ",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }

    // 🟢 MẶC ĐỊNH (Pending)
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.cardBorder),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on_outlined, color: AppTheme.primary),
                ),
                title: const Text("Địa điểm thi đấu", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                subtitle: const Text(
                  "Sân Pickleball Xa La - Sân số 89",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.darkSlate),
                ),
              ),
              const Divider(height: 1, indent: 56, endIndent: 16, color: AppTheme.cardBorder),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.schedule, color: AppTheme.primary),
                ),
                title: const Text("Thời gian dự kiến", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                subtitle: const Text(
                  "Ngay bây giờ (Cần Check-in)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.darkSlate),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          "Vui lòng di chuyển ra sân và quét mã QR để xác nhận có mặt!",
          textAlign: TextAlign.center,
          style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.glowShadow(AppTheme.primary),
            ),
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
                    builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                  );

                  final result = await CheckInService.verifyQrCode(
                      matchId,
                      currentUserId,
                      scannedQrCode
                  );

                  if (context.mounted) Navigator.pop(context);

                  if (result != null && result.startsWith("ERROR:")) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.replaceAll("ERROR: ", "")), backgroundColor: Colors.redAccent),
                    );
                  } else {
                    if (result == 'In_Progress') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Cả 2 đã Check-in! Trận đấu BẮT ĐẦU 🚀"), backgroundColor: AppTheme.primary),
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
                        const SnackBar(content: Text("Check-in thành công! Đang chờ đối thủ..."), backgroundColor: AppTheme.orange),
                      );
                    }
                  }
                }
              },
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label: const Text(
                "QUÉT QR CHECK-IN",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkSlate)),
      ],
    );
  }

  Widget _buildPlayerInfo(String name, int elo, String avatarUrl) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "$elo ELO",
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}