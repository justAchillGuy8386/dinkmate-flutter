import 'package:flutter/material.dart';
import '../../core/api/auth_service.dart';
import '../../features/main_wrapper_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Biến trạng thái để hiện vòng xoay loading

  Future<void> _handleLogin() async {
    setState(() { _isLoading = true; }); // Bắt đầu quay

    try {
      // Gọi lên Server Next.js
      final result = await AuthService.login(
          _phoneController.text.trim(),
          _passwordController.text.trim()
      );

      final userData = result['data']; // Lấy cục data chứa thông tin Nguyễn Văn Tín

      // Nếu component còn tồn tại trên màn hình thì thực hiện chuyển trang
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainWrapper(
              userName: userData['full_name'],
              elo: userData['elo_rating'],
            ),
          ),
        );
      }
    } catch (e) {
      // Bắn thông báo lỗi màu đỏ (nếu sai pass hoặc mất mạng)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; }); // Dừng quay
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.sports_tennis, size: 80, color: Colors.green),
              const SizedBox(height: 16),
              const Text('DinkMate', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
              const Text('Tìm đối thủ Pickleball xứng tầm', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 48),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Số điện thoại', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mật khẩu', prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 24),

              // Nút bấm có trạng thái Loading
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Đăng Nhập', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}