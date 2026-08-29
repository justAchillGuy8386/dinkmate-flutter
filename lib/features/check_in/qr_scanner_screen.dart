import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanned = false;

  final MobileScannerController _scannerController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  void _handleQrScanned(BarcodeCapture capture) {
    if (_isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      _processScannedData(barcodes.first.rawValue!);
    }
  }

  void _processScannedData(String qrData) {
    setState(() {
      _isScanned = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã quét được mã: $qrData'),
        backgroundColor: AppTheme.primary,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context, qrData);
      }
    });
  }

  Future<void> _scanFromGallery() async {
    if (_isScanned) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final BarcodeCapture? capture = await _scannerController.analyzeImage(image.path);

    if (capture != null && capture.barcodes.isNotEmpty && capture.barcodes.first.rawValue != null) {
      _processScannedData(capture.barcodes.first.rawValue!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy mã QR nào trong ảnh này!'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR Ra Sân'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleQrScanned,
          ),

          Container(decoration: BoxDecoration(color: Colors.black.withOpacity(0.55))),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.voltLime, width: 4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppTheme.glowShadow(AppTheme.voltLime),
              ),
            ),
          ),

          const Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Text(
              'Đưa mã QR của sân vào giữa khung hình để check-in',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),

          Positioned(
            bottom: 40,
            left: 40,
            right: 40,
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _scanFromGallery,
                icon: const Icon(Icons.photo_library, color: AppTheme.primary),
                label: const Text('Tải ảnh QR từ Thư viện', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}