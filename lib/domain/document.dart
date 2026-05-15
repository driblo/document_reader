import 'dart:typed_data';

/// A reference to a document on disk. Stays as a value object — no I/O
/// happens here; readers and handlers do that.
class DocumentRef {
  const DocumentRef({
    required this.path,
    required this.displayName,
    required this.mimeType,
    required this.sizeBytes,
    this.lastModified,
  });

  final String path;
  final String displayName;
  final String mimeType;
  final int sizeBytes;
  final DateTime? lastModified;

  String get extension {
    final i = displayName.lastIndexOf('.');
    return i == -1 ? '' : displayName.substring(i + 1).toLowerCase();
  }
}

class Thumbnail {
  const Thumbnail(this.bytes, {this.width, this.height});
  final Uint8List bytes;
  final int? width;
  final int? height;
}
