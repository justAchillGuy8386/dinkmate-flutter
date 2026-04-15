import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // Biến cờ để tránh việc quét 1 mã QR liên tục hàng chục lần trong 1 giây
  bool _isScanned = false;

  void _handleQrScanned(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      final String qrData = barcodes.first.rawValue!;

      setState(() {
        _isScanned = true; // Khóa lại, không cho quét nữa
      });

      // Tạm thời in ra màn hình, lát nữa chúng ta sẽ gọi API Check-in tại đây
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã quét được mã: $qrData'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Đóng màn hình quét, trả dữ liệu về màn hình trước
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context, qrData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR Ra Sân'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Khung Camera
          MobileScanner(
            onDetect: _handleQrScanned,
          ),

          // Lớp phủ làm mờ xung quanh (Tạo hiệu ứng khung ngắm)
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Khung vuông ở giữa màn hình
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Dòng chữ hướng dẫn
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Đưa mã QR của sân vào giữa khung hình',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}