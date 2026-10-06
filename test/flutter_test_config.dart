import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Auto-loaded by flutter_test before every test file.
/// Disables google_fonts runtime fetching so widget tests stay hermetic
/// (theme falls back to the system font instead of hitting the network).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}
