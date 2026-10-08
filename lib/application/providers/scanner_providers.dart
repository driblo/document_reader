import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/document.dart';
import '../../domain/fs_entry.dart';
import '../services/device_scanner_service.dart';
import '../services/folder_browser_service.dart';

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

final folderBrowserProvider = Provider<FolderBrowserService>(
  (_) => FolderBrowserService(),
);

/// Requests permission then returns the browsable storage roots
/// (internal storage, SD card, ...).
final storageVolumesProvider = FutureProvider<List<StorageVolume>>((ref) async {
  final scanner = ref.read(deviceScannerProvider);
  await scanner.requestPermission();
  return ref.read(folderBrowserProvider).volumes();
});

/// Non-recursive listing of one directory — folders first, then files,
/// both alphabetical. Re-fetch with ref.invalidate(folderListingProvider(path)).
final folderListingProvider =
    FutureProvider.family<List<FsEntry>, String>((ref, path) {
  return ref.read(folderBrowserProvider).list(path);
});

/// Whether the Library tab shows a thumbnail grid instead of a list.
final libraryGridViewProvider = StateProvider<bool>((_) => false);
