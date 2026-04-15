import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart'; // Thư viện chọn ảnh mới thêm

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanned = false;

  // Tạo bộ điều khiển riêng cho Scanner để có thể gọi hàm quét ảnh tĩnh
  final MobileScannerController _scannerController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  void _handleQrScanned(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _processScannedData(barcodes.first.rawValue!);
    }
  }

  // Hàm xử lý chung khi quét thành công (từ Camera hoặc từ Ảnh)
  void _processScannedData(String qrData) {
    setState(() {
      _isScanned = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã quét được mã: $qrData'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context, qrData);
      }
    });
  }

  // Hàm MỚI: Mở thư viện ảnh và quét
  Future<void> _scanFromGallery() async {
    if (_isScanned) return;

    // 1. Mở thư viện để chọn ảnh
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return; // Người dùng bấm Hủy không chọn nữa

    // 2. Đưa ảnh vào MobileScanner để phân tích
    final BarcodeCapture? capture = await _scannerController.analyzeImage(image.path);

    // 3. Xử lý kết quả
    if (capture != null && capture.barcodes.isNotEmpty && capture.barcodes.first.rawValue != null) {
      _processScannedData(capture.barcodes.first.rawValue!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy mã QR nào trong ảnh này!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose(); // Nhớ dọn dẹp bộ nhớ khi đóng màn hình
    super.dispose();
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
          MobileScanner(
            controller: _scannerController, // Gắn Controller vào Camera
            onDetect: _handleQrScanned,
          ),

          Container(decoration: BoxDecoration(color: Colors.black.withOpacity(0.5))),

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

          const Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Text(
              'Đưa mã QR của sân vào giữa khung hình',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // NÚT MỚI: Tải ảnh lên
          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: ElevatedButton.icon(
              onPressed: _scanFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Tải ảnh QR từ Thư viện'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}