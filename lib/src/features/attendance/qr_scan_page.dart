import 'package:flutter/material.dart';
import 'package:gym_member_app/src/features/attendance/attendance_qr.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key, required this.expectedGymId});

  final String expectedGymId;

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    final payload = checkInQrPayloadFromInput(raw);
    if (payload == null) {
      _showError('Invalid QR code. Scan the gym attendance QR.');
      return;
    }

    final gymId = gymIdFromAttendanceQr(payload);
    if (gymId != widget.expectedGymId) {
      _showError('This QR belongs to another gym.');
      return;
    }

    _handled = true;
    Navigator.of(context).pop(payload);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan gym QR')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(onDetect: _onDetect),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Point your camera at the check-in QR displayed at your gym entrance.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}
