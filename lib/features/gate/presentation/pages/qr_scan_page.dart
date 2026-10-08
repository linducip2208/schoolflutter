import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../../emergency/data/emergency_repository.dart';

/// Scan QR gerbang (driver/security/petugas).
/// Backend: `POST /qr/scan {payload}`.
class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final EmergencyRepository _repo = EmergencyRepository();
  bool _granted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ask();
  }

  Future<void> _ask() async {
    final PermissionStatus s = await Permission.camera.request();
    if (mounted) setState(() => _granted = s.isGranted);
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final List<Barcode> codes = capture.barcodes;
    if (codes.isEmpty) return;
    final String? raw = codes.first.rawValue;
    if (raw == null || raw.isEmpty || !mounted) return;
    setState(() => _busy = true);
    try {
      final Map<String, dynamic> res = await _repo.qrScan(raw);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message']?.toString() ?? 'Scan tercatat.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Gerbang')),
      body: !_granted
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Izin kamera diperlukan.'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _ask,
                    child: const Text('Minta Izin'),
                  ),
                ],
              ),
            )
          : MobileScanner(onDetect: _onDetect),
    );
  }
}
