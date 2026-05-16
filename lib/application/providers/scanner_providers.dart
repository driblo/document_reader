import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/document.dart';
import '../services/device_scanner_service.dart';

final deviceScannerProvider = Provider<DeviceScannerService>(
  (_) => DeviceScannerService(),
);

/// Requests permission then returns all found files, newest first.
/// Re-fetch by calling ref.invalidate(libraryFilesProvider).
final libraryFilesProvider = FutureProvider<List<DocumentRef>>((ref) async {
  final scanner = ref.read(deviceScannerProvider);
  await scanner.requestPermission();
  return scanner.scan();
});
