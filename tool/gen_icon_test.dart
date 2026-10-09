import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Generates SikadPro launcher icons from a vector painter (no binaries).
/// Run once: flutter test tool/gen_icon_test.dart
/// Design: deep-blue rounded square, white graduation cap, gold tassel.
class SikadLogo extends CustomPainter {
  const SikadLogo({this.fullBleed = true});

  final bool fullBleed;

  static const Color deep = Color(0xFF1E40AF);
  static const Color bright = Color(0xFF2563EB);
  static const Color gold = Color(0xFFF59E0B);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    if (fullBleed) {
      final Rect rect = Offset.zero & size;
      final Paint bg = Paint()
        ..shader = const LinearGradient(
          colors: <Color>[deep, bright],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(w * 0.225)),
        bg,
      );
    }
    // Scale + center the cap motif.
    final double s = w / 512;
    canvas.save();
    canvas.translate(w / 2, h * 0.52);
    canvas.scale(s, s);
    canvas.translate(-256, -256);
    _cap(canvas);
    canvas.restore();
  }

  void _cap(Canvas canvas) {
    final Paint white = Paint()..color = Colors.white;
    final Paint whiteSoft = Paint()..color = const Color(0xFFDBEAFE);
    final Paint goldP = Paint()..color = gold;

    // Mortarboard (wide diamond).
    final Path board = Path()
      ..moveTo(256, 150)
      ..lineTo(452, 236)
      ..lineTo(256, 322)
      ..lineTo(60, 236)
      ..close();
    canvas.drawPath(board, white);

    // Head band below.
    final Path band = Path()
      ..moveTo(176, 272)
      ..lineTo(176, 330)
      ..quadraticBezierTo(176, 366, 256, 366)
      ..quadraticBezierTo(336, 366, 336, 330)
      ..lineTo(336, 272)
      ..lineTo(256, 308)
      ..close();
    canvas.drawPath(band, whiteSoft);

    // Tassel cord + gold bobble.
    canvas.drawLine(
      const Offset(452, 236),
      const Offset(452, 340),
      white..strokeWidth = 10,
    );
    canvas.drawCircle(const Offset(452, 356), 20, goldP);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<Uint8List> _render(
    CustomPainter painter, int size, double pad) async {
  final ui.PictureRecorder rec = ui.PictureRecorder();
  final Canvas canvas = Canvas(rec);
  if (pad > 0) {
    final double inset = size * pad;
    canvas.translate(inset, inset);
    painter.paint(canvas, Size(size - inset * 2, size - inset * 2));
  } else {
    painter.paint(canvas, Size(size.toDouble(), size.toDouble()));
  }
  final ui.Image img = await rec
      .endRecording()
      .toImage(size, size);
  final ByteData? bytes =
      await img.toByteData(format: ui.ImageByteFormat.png);
  return bytes!.buffer.asUint8List();
}

Future<void> _write(String path, Uint8List bytes) async {
  final File f = File(path);
  await f.parent.create(recursive: true);
  await f.writeAsBytes(bytes);
  // ignore: avoid_print
  print('wrote $path (${bytes.length}B)');
}

void main() {
  test('generate SikadPro icons', () async {
    const String andRes =
        'android/app/src/main/res';
    const String iosIcon =
        'ios/Runner/Assets.xcassets/AppIcon.appiconset';

    // Android legacy (full-bleed, slight padding like stock icons).
    const Map<String, int> legacy = <String, int>{
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };
    for (final MapEntry<String, int> e in legacy.entries) {
      await _write(
        '$andRes/${e.key}/ic_launcher.png',
        await _render(const SikadLogo(fullBleed: true), e.value, 0.06),
      );
    }

    // Android adaptive foreground (transparent, motif ~62%).
    const Map<String, int> fg = <String, int>{
      'mipmap-mdpi': 108,
      'mipmap-hdpi': 162,
      'mipmap-xhdpi': 216,
      'mipmap-xxhdpi': 324,
      'mipmap-xxxhdpi': 432,
    };
    for (final MapEntry<String, int> e in fg.entries) {
      await _write(
        '$andRes/${e.key}/ic_launcher_foreground.png',
        await _render(const SikadLogo(fullBleed: false), e.value, 0.19),
      );
    }

    // iOS full set (full-bleed design; OS masks corners).
    final Map<String, int> ios = <String, int>{
      'Icon-App-20x20@1x.png': 20,
      'Icon-App-20x20@2x.png': 40,
      'Icon-App-20x20@3x.png': 60,
      'Icon-App-29x29@1x.png': 29,
      'Icon-App-29x29@2x.png': 58,
      'Icon-App-29x29@3x.png': 87,
      'Icon-App-40x40@1x.png': 40,
      'Icon-App-40x40@2x.png': 80,
      'Icon-App-40x40@3x.png': 120,
      'Icon-App-60x60@2x.png': 120,
      'Icon-App-60x60@3x.png': 180,
      'Icon-App-76x76@1x.png': 76,
      'Icon-App-76x76@2x.png': 152,
      'Icon-App-83.5x83.5@2x.png': 167,
      'Icon-App-1024x1024@1x.png': 1024,
    };
    for (final MapEntry<String, int> e in ios.entries) {
      await _write(
        '$iosIcon/${e.key}',
        await _render(const SikadLogo(fullBleed: true), e.value, 0.0),
      );
    }
  });
}
