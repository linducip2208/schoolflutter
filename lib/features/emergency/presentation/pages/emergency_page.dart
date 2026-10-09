import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../data/emergency_repository.dart';

/// Tombol darurat + kontak + riwayat.
/// Backend: `/emergency/panic|recent|contacts`.
/// Panic requires GPS coordinates (backend validates
/// latitude/longitude) — requested only when the button is used.
class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  Future<Position?> _position(BuildContext context) async {
    bool service = false;
    try {
      service = await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return null;
    }
    if (!service) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aktifkan GPS untuk sinyal darurat.')),
        );
      }
      return null;
    }
    LocationPermission perm = LocationPermission.denied;
    try {
      perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
    } catch (_) {
      return null;
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Izin lokasi ditolak — sinyal butuh lokasi.')),
        );
      }
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 20));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final EmergencyRepository repo = EmergencyRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Darurat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              minimumSize: const Size(double.infinity, 56),
            ),
            icon: const Icon(Icons.sos_outlined),
            label: const Text('PANIC BUTTON'),
            onPressed: () async {
              final bool ok = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext d) => AlertDialog(
                      title: const Text('Kirim sinyal darurat?'),
                      content: const Text(
                          'Sekolah akan menerima lokasi dan identitas Anda.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(d).pop(false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(d).pop(true),
                          child: const Text('Kirim'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (ok && context.mounted) {
                final Position? pos = await _position(context);
                if (pos == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.panic(lat: pos.latitude, lng: pos.longitude),
                );
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Kontak Darurat', style: Theme.of(context).textTheme.titleSmall),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: repo.contacts(),
            builder: (BuildContext c,
                AsyncSnapshot<List<Map<String, dynamic>>> snap) {
              final List<Map<String, dynamic>> items =
                  snap.data ?? const <Map<String, dynamic>>[];
              if (!snap.hasData) {
                return const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator());
              }
              if (items.isEmpty) {
                return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Belum ada kontak darurat.'));
              }
              return Column(
                children: <Widget>[
                  for (final Map<String, dynamic> e in items)
                    Card(
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.phone_outlined),
                        title: Text(e['name']?.toString() ?? '-'),
                        subtitle: Text(e['phone']?.toString() ?? '-'),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text('Riwayat Sinyal', style: Theme.of(context).textTheme.titleSmall),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: repo.recent(),
            builder: (BuildContext c,
                AsyncSnapshot<List<Map<String, dynamic>>> snap) {
              final List<Map<String, dynamic>> items =
                  snap.data ?? const <Map<String, dynamic>>[];
              if (!snap.hasData) {
                return const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator());
              }
              if (items.isEmpty) {
                return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Belum ada sinyal darurat.'));
              }
              return Column(
                children: <Widget>[
                  for (final Map<String, dynamic> e in items)
                    Card(
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.sos_outlined),
                        title: Text(e['message']?.toString() ?? 'Sinyal'),
                        subtitle: Text(
                            '${e['created_at'] ?? '-'} • Status ${e['status'] ?? '-'}'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
