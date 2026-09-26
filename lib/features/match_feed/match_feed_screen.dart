import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api/match_service.dart';
import '../../core/api/court_service.dart';
import '../../core/api/api_config.dart';
import '../../core/api/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/models.dart';

class MatchFeedScreen extends StatefulWidget {
  final String userName;
  final int elo;

  const MatchFeedScreen({super.key, required this.userName, required this.elo});

  @override
  State<MatchFeedScreen> createState() => _MatchFeedScreenState();
}

class _MatchFeedScreenState extends State<MatchFeedScreen> {
  List<MatchRequest> _matches = [];
  List<CourtModel> _courts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await MatchService.getAvailableMatches();
      final courts = await CourtService.getCourts();
      setState(() {
        _matches = data;
        _courts = courts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadMatches();
  }

  Future<void> _submitCasualMatch(DateTime scheduledTime, String courtId) async {
    final String myUserId = AuthService.currentUser?['id'] ?? "";
    if (myUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi: Chưa đăng nhập!"), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang đăng kèo lên Bảng tin...')),
      );

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/match-requests'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'creator_id': myUserId,
          'court_id': courtId,
          'scheduled_time': scheduledTime.toIso8601String(),
          'is_ranked': false
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng kèo thành công!'), backgroundColor: AppTheme.primary),
          );
          _handleRefresh();
        }
      } else {
        if (mounted) {
          final err = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err['error'] ?? 'Lỗi tạo kèo'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể kết nối đến máy chủ"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCreateMatchBottomSheet() {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedCourtId = _courts.isNotEmpty ? _courts.first.id : "123456789";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Center(
                    child: Text(
                      'Tạo Kèo Giao Lưu',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkSlate,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Chọn sân thi đấu
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.stadium_outlined, color: AppTheme.primary),
                        const SizedBox(width: 14),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _courts.any((c) => c.id == selectedCourtId)
                                  ? selectedCourtId
                                  : (_courts.isNotEmpty ? _courts.first.id : null),
                              isExpanded: true,
                              hint: const Text("Chọn sân thi đấu", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                              items: _courts.map((court) {
                                return DropdownMenuItem<String>(
                                  value: court.id,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        court.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.darkSlate),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (court.address.isNotEmpty)
                                        Text(
                                          court.address,
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (newId) {
                                if (newId != null) {
                                  setModalState(() => selectedCourtId = newId);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    leading: const Icon(Icons.calendar_today_outlined, color: AppTheme.primary),
                    title: const Text("Ngày thi đấu", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    subtitle: Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkSlate),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
                          child: child!,
                        ),
                      );
                      if (date != null) setModalState(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 14),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.cardBorder),
                    ),
                    leading: const Icon(Icons.access_time_outlined, color: AppTheme.primary),
                    title: const Text("Giờ bắt đầu", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    subtitle: Text(
                      selectedTime.format(context),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkSlate),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
                          child: child!,
                        ),
                      );
                      if (time != null) setModalState(() => selectedTime = time);
                    },
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.glowShadow(AppTheme.primary),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          final scheduledTime = DateTime(
                            selectedDate.year, selectedDate.month, selectedDate.day,
                            selectedTime.hour, selectedTime.minute,
                          );

                          Navigator.pop(context);
                          _submitCasualMatch(scheduledTime, selectedCourtId);
                        },
                        child: const Text(
                          'ĐĂNG KÈO LÊN BẢNG TIN',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Kèo Đấu Đang Chờ'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateMatchBottomSheet,
        backgroundColor: AppTheme.primary,
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tạo Kèo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    if (_errorMessage != null) {
      return Center(child: Text('Lỗi: $_errorMessage', style: const TextStyle(color: Colors.redAccent)));
    }

    if (_matches.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppTheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sports_tennis, size: 64, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chưa có kèo đấu nào đang chờ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkSlate),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hãy trở thành người đầu tiên đăng kèo giao lưu nhé!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 85),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          final String myUserId = AuthService.currentUser?['id'] ?? "";
          final bool isMyMatch = match.creatorName == widget.userName;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMyMatch ? AppTheme.orange : AppTheme.cardBorder,
                width: isMyMatch ? 1.5 : 1,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Avatar + Creator Info + ELO Badge
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primary.withOpacity(0.12),
                        radius: 24,
                        child: const Icon(Icons.person, color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match.creatorName + (isMyMatch ? " (Bạn)" : ""),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: AppTheme.darkSlate,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.workspace_premium, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text(
                                  "${match.creatorElo} ELO",
                                  style: const TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isMyMatch)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Kèo của bạn",
                            style: TextStyle(color: AppTheme.orange, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Middle Row: Court & Time Details
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          match.courtName,
                          style: const TextStyle(color: AppTheme.darkSlate, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Bắt đầu: ${match.startTime.hour}:${match.startTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bottom Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: isMyMatch
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Đang chờ người nhận kèo...",
                                  style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text("HỦY KÈO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      title: const Text('Hủy kèo giao lưu', style: TextStyle(fontWeight: FontWeight.bold)),
                                      content: const Text('Bạn có chắc chắn muốn hủy kèo giao lưu này không?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Không', style: TextStyle(color: Colors.grey)),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            final ok = await MatchService.cancelMatchRequest(userId: myUserId, requestId: match.id);
                                            if (context.mounted) {
                                              if (ok) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Đã hủy kèo giao lưu thành công!'), backgroundColor: Colors.orange),
                                                );
                                                _loadMatches();
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Không thể hủy kèo, vui lòng thử lại!'), backgroundColor: Colors.red),
                                                );
                                              }
                                            }
                                          },
                                          child: const Text('Đồng ý hủy'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        : Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.handshake_outlined, size: 20, color: Colors.white),
                        label: const Text('NHẬN KÈO NGAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text('Xác nhận nhận kèo', style: TextStyle(fontWeight: FontWeight.bold)),
                              content: Text('Bạn có chắc muốn giao lưu trận đấu với ${match.creatorName} không?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    setState(() {
                                      _matches.removeAt(index);
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Đang xử lý nhận kèo...')),
                                    );

                                    final success = await MatchService.acceptMatch(match.id, myUserId);

                                    if (context.mounted) {
                                      if (success) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Nhận kèo thành công! Hãy vào "Trận của tôi" để theo dõi.'),
                                            backgroundColor: AppTheme.primary,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Không thể nhận kèo. Kèo đã bị hủy hoặc có người khác nhận!'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        _loadMatches();
                                      }
                                    }
                                  },
                                  child: const Text('Đồng ý'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}