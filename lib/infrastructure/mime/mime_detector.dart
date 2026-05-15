import 'dart:io';

/// Tiny utility that combines extension lookup with magic-byte sniffing
/// of the first ~16 bytes. Handlers ultimately decide whether they can
/// open a file; this exists so the recents list can show a sensible
/// MIME label even when the OS metadata is `application/octet-stream`.
class MimeDetector {
  const MimeDetector();

  static const _byExtension = <String, String>{
    'pdf': 'application/pdf',
    'txt': 'text/plain',
    'log': 'text/plain',
    'csv': 'text/csv',
    'tsv': 'text/tab-separated-values',
    'md': 'text/markdown',
    'markdown': 'text/markdown',
    'html': 'text/html',
    'htm': 'text/html',
    'xhtml': 'application/xhtml+xml',
    'epub': 'application/epub+zip',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
    'gif': 'image/gif',
    'bmp': 'image/bmp',
    'heic': 'image/heic',
    'heif': 'image/heif',
    'doc': 'application/msword',
    'docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx':
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'odt': 'application/vnd.oasis.opendocument.text',
    'ods': 'application/vnd.oasis.opendocument.spreadsheet',
    'odp': 'application/vnd.oasis.opendocument.presentation',
    'rtf': 'application/rtf',
  };

  String fromExtension(String ext) =>
      _byExtension[ext.toLowerCase()] ?? 'application/octet-stream';

  Future<List<int>> readHeader(File file, {int length = 16}) async {
    final raf = await file.open();
    try {
      final size = await file.length();
      final n = size < length ? size : length;
      return raf.readSync(n);
    } finally {
      await raf.close();
    }
  }
}
