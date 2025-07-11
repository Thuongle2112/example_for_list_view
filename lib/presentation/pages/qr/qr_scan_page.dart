import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'qr_test_page.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  MobileScannerController controller = MobileScannerController();
  bool isScanning = true;
  String? lastScannedCode;
  String? errorMessage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(capture) {
    if (!isScanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    print('QR Scan: Detected  [38;5;2m [48;5;0m [1m [4m [3m [9m [7m [5m [8m [6m [10m [11m [12m [13m [14m [15m [16m [17m [18m [19m [20m [21m [22m [23m [24m [25m [26m [27m [28m [29m [30m [31m [32m [33m [34m [35m [36m [37m [38m [39m [40m [41m [42m [43m [44m [45m [46m [47m [48m [49m [50m [51m [52m [53m [54m [55m [56m [57m [58m [59m [60m [61m [62m [63m [64m [65m [66m [67m [68m [69m [70m [71m [72m [73m [74m [75m [76m [77m [78m [79m [80m [81m [82m [83m [84m [85m [86m [87m [88m [89m [90m [91m [92m [93m [94m [95m [96m [97m [98m [99m [100m');
    for (final barcode in barcodes) {
      print('QR Scan: Barcode type:  [38;5;2m [48;5;0m [1m [4m [3m [9m [7m [5m [8m [6m [10m [11m [12m [13m [14m [15m [16m [17m [18m [19m [20m [21m [22m [23m [24m [25m [26m [27m [28m [29m [30m [31m [32m [33m [34m [35m [36m [37m [38m [39m [40m [41m [42m [43m [44m [45m [46m [47m [48m [49m [50m [51m [52m [53m [54m [55m [56m [57m [58m [59m [60m [61m [62m [63m [64m [65m [66m [67m [68m [69m [70m [71m [72m [73m [74m [75m [76m [77m [78m [79m [80m [81m [82m [83m [84m [85m [86m [87m [88m [89m [90m [91m [92m [93m [94m [95m [96m [97m [98m [99m [100m, value: ${barcode.rawValue}');
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() {
          lastScannedCode = barcode.rawValue;
          isScanning = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR Code detected: ${barcode.rawValue}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _processQrResult(barcode.rawValue!);
        break;
      }
    }
  }

  void _processQrResult(String qrData) {
    try {
      // Try to parse as JSON
      final Map<String, dynamic> data = json.decode(qrData);
      
      // Return the parsed data
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop(data);
        }
      });
    } catch (e) {
      // If not JSON, return as plain text
      print('QR data is not JSON: $qrData');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop(qrData);
        }
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final inputImage = mlkit.InputImage.fromFilePath(image.path);
        final barcodeScanner = mlkit.BarcodeScanner(formats: [mlkit.BarcodeFormat.qrCode]);
        final barcodes = await barcodeScanner.processImage(inputImage);
        await barcodeScanner.close();
        if (barcodes.isNotEmpty) {
          final qr = barcodes.firstWhere(
            (b) => b.rawValue != null && b.rawValue!.isNotEmpty,
            orElse: () => barcodes.first,
          );
          if (qr.rawValue != null && qr.rawValue!.isNotEmpty) {
            setState(() {
              lastScannedCode = qr.rawValue;
              isScanning = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('QR Code detected: ${qr.rawValue}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            _processQrResult(qr.rawValue!);
            return;
          }
        }
        // Không tìm thấy QR hợp lệ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không phát hiện mã QR hợp lệ trong ảnh!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi quét QR từ ảnh: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR to open album'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.image, color: Colors.white),
            tooltip: 'Chọn ảnh từ thư viện',
            onPressed: _pickImageFromGallery,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code, color: Colors.white),
            tooltip: 'Test QR Code',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QrTestPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                return Icon(
                  state == CameraFacing.front ? Icons.camera_front : Icons.camera_rear,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, child) {
              print('QR Scan Error: $error');
              setState(() {
                errorMessage = error.errorDetails?.message ?? 'Camera error occurred';
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Error',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          errorMessage = null;
                        });
                        controller.start();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Scanning overlay
          if (isScanning && errorMessage == null)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
              ),
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      // Corner indicators
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.green, width: 4),
                              left: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.green, width: 4),
                              right: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.green, width: 4),
                              left: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.green, width: 4),
                              right: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Instructions
          if (isScanning && errorMessage == null)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Position QR code within the frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'The code will be automatically detected',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          
          // Success indicator
          if (lastScannedCode != null)
            Container(
              color: Colors.green.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'QR Code Detected!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Opening album...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 