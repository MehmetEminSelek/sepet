import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import '../constants/app_colors.dart';

// QR Kod Gösterme Widget'ı
class QRCodeDisplayWidget extends StatelessWidget {
  final String data;
  final String title;
  final String subtitle;
  final Color? color;
  final IconData? icon;

  const QRCodeDisplayWidget({
    super.key,
    required this.data,
    required this.title,
    required this.subtitle,
    this.color,
    this.icon,
  });

  // Kodu daha okunabilir formatta göster
  String _formatCode(String code) {
    if (code.length == 12) {
      // 12 haneli kodları 2-4-6 formatında göster (SP-1234-ABCDEF)
      return '${code.substring(0, 2)}-${code.substring(2, 6)}-${code.substring(6, 12)}';
    } else if (code.length == 8) {
      // Eski 8 haneli kodları 2-3-3 formatında göster (SP-123-ABC)
      return '${code.substring(0, 2)}-${code.substring(2, 5)}-${code.substring(5, 8)}';
    }
    return code; // Diğer kodları olduğu gibi göster
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (color ?? AppColors.primaryBlue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: color ?? AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // QR Code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (color ?? AppColors.primaryBlue).withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
            const SizedBox(height: 16),

            // Kod Metni
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.dividerColor,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatCode(data),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: data));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kod kopyalandı: $data'),
                          backgroundColor: AppColors.successGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kapat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: data));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kod kopyalandı: $data'),
                          backgroundColor: AppColors.successGreen,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Kopyala'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color ?? AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// QR Kod Okuma Widget'ı - Web uyumlu
class QRCodeScannerWidget extends StatefulWidget {
  final Function(String) onCodeScanned;
  final String title;
  final String subtitle;

  const QRCodeScannerWidget({
    super.key,
    required this.onCodeScanned,
    required this.title,
    required this.subtitle,
  });

  @override
  State<QRCodeScannerWidget> createState() => _QRCodeScannerWidgetState();
}

class _QRCodeScannerWidgetState extends State<QRCodeScannerWidget> {
  @override
  Widget build(BuildContext context) {
    // Web platformunda QR kod tarayıcı desteklenmiyor
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.web_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'QR Kod Tarayıcı Web\'de Desteklenmiyor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Lütfen mobil cihazınızı kullanın veya kodu manuel olarak girin',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
        ),
      );
    }

    // Mobil platformda QR kod tarayıcı
    return _MobileQRScanner(
      onCodeScanned: widget.onCodeScanned,
      title: widget.title,
      subtitle: widget.subtitle,
    );
  }
}

// Mobil QR Scanner - ai_barcode_scanner kullanarak
class _MobileQRScanner extends StatefulWidget {
  final Function(String) onCodeScanned;
  final String title;
  final String subtitle;

  const _MobileQRScanner({
    required this.onCodeScanned,
    required this.title,
    required this.subtitle,
  });

  @override
  State<_MobileQRScanner> createState() => _MobileQRScannerState();
}

class _MobileQRScannerState extends State<_MobileQRScanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Açıklama
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // QR Scanner
          Expanded(
            child: AiBarcodeScanner(
              onDetect: (BarcodeCapture capture) {
                final String? scannedValue = capture.barcodes.first.rawValue;
                if (scannedValue != null) {
                  widget.onCodeScanned(scannedValue);
                  Navigator.pop(context);
                }
              },
              onDispose: () {
                debugPrint("Barcode scanner disposed!");
              },
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.noDuplicates,
              ),
            ),
          ),

          // Alt butonlar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                    ),
                    child: const Text('İptal'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
