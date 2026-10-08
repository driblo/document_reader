/// A single entry (file or folder) in a raw filesystem directory listing.
/// Unlike [DocumentRef], this includes folders and files of any type —
/// the browse tab shows the phone's real folder structure, not just
/// documents this app knows how to open.
class FsEntry {
  const FsEntry({
    required this.path,
    required this.name,
    required this.isDirectory,
    this.sizeBytes,
    this.lastModified,
  });

  final String path;
  final String name;
  final bool isDirectory;
  final int? sizeBytes;
  final DateTime? lastModified;

  String get extension {
    if (isDirectory) return '';
    final i = name.lastIndexOf('.');
    return i == -1 ? '' : name.substring(i + 1).toLowerCase();
  }
}

/// A browsable storage root, e.g. internal storage or an SD card.
class StorageVolume {
  const StorageVolume({required this.label, required this.path});
  final String label;
  final String path;
}
