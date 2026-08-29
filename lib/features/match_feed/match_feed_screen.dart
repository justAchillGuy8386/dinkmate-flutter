import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/api/match_service.dart';
import '../../core/api/api_config.dart';
import '../../core/api/auth_service.dart';
import '../../core/utils/models.dart';

class MatchFeedScreen extends StatefulWidget {
  final String userName;
  final int elo;

  const MatchFeedScreen({super.key, required this.userName, required this.elo});

  @override
  State<MatchFeedScreen> createState() => _MatchFeedScreenState();
}

class _MatchFeedScreenState extends State<MatchFeedScreen> {
  // Thay thế FutureBuilder bằng danh sách động để dễ thao tác Xóa Nóng
  List<MatchRequest> _matches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  // Hàm tải dữ liệu
  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await MatchService.getAvailableMatches();
      setState(() {
        _matches = data;
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

  Future<void> _submitCasualMatch(DateTime scheduledTime) async {
    final String myUserId = AuthService.currentUser?['id'] ?? "";
    if (myUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lỗi: Chưa đăng nhập!"), backgroundColor: Colors.red));
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
          'court_id': "123456789",
          'scheduled_time': scheduledTime.toIso8601String(),
          'is_ranked': false
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng kèo thành công!'), backgroundColor: Colors.green),
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

  // HÀM HIỂN THỊ MENU CHỌN GIỜ ĐÁNH
  void _showCreateMatchBottomSheet() {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('Tạo Kèo Giao Lưu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                  ),
                  const SizedBox(height: 20),

                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade300)),
                    leading: const Icon(Icons.calendar_today, color: Colors.green),
                    title: const Text("Chọn Ngày Thi Đấu", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    subtitle: Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Colors.green)),
                          child: child!,
                        ),
                      );
                      if (date != null) setModalState(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 12),

                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade300)),
                    leading: const Icon(Icons.access_time, color: Colors.green),
                    title: const Text("Chọn Giờ Bắt Đầu", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    subtitle: Text(selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Colors.green)),
                          child: child!,
                        ),
                      );
                      if (time != null) setModalState(() => selectedTime = time);
                    },
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      onPressed: () {
                        final scheduledTime = DateTime(
                          selectedDate.year, selectedDate.month, selectedDate.day,
                          selectedTime.hour, selectedTime.minute,
                        );

                        Navigator.pop(context);
                        _submitCasualMatch(scheduledTime);
                      },
                      child: const Text('ĐĂNG KÈO LÊN BẢNG TIN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // GIAO DIỆN CHÍNH
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kèo Đấu Đang Chờ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateMatchBottomSheet,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tạo Kèo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Trạng thái Loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    // 2. Trạng thái Lỗi
    if (_errorMessage != null) {
      return Center(child: Text('Lỗi: $_errorMessage', style: const TextStyle(color: Colors.red)));
    }

    // 3. Trạng thái Trống (Không có kèo)
    if (_matches.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: Colors.green,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            const Center(
              child: Column(
                children: [
                  Icon(Icons.sports_tennis, size: 80, color: Colors.black12),
                  SizedBox(height: 16),
                  Text(
                    'Hiện chưa có kèo đấu nào.\nHãy trở thành người đầu tiên tạo kèo!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 4. Trạng thái có dữ liệu
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.green,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          final match = _matches[index];
          final String myUserId = AuthService.currentUser?['id'] ?? "";
          final bool isMyMatch = match.creatorName == widget.userName;

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: isMyMatch ? const BorderSide(color: Colors.orange, width: 1.5) : BorderSide.none,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: const Icon(Icons.sports_tennis, color: Colors.green),
              ),
              title: Text(
                  match.creatorName + (isMyMatch ? " (Bạn)" : ""),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('ELO: ${match.creatorElo} • ${match.courtName}'),
                  const SizedBox(height: 4),
                  Text(
                      'Bắt đầu: ${match.startTime.hour}:${match.startTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
              trailing: isMyMatch
                  ? const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Text("Đang đợi...", style: TextStyle(color: Colors.orange, fontStyle: FontStyle.italic)),
              )
                  : ElevatedButton.icon(
                icon: const Icon(Icons.handshake, size: 18),
                label: const Text('Nhận Kèo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Xác nhận nhận kèo'),
                      content: Text('Bạn có chắc muốn giao lưu với ${match.creatorName} không?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
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
                                    backgroundColor: Colors.green,
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
          );
        },
      ),
    );
  }
}