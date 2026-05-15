import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:pdfx/pdfx.dart';

import '../../domain/document.dart';
import '../../presentation/readers/pdf_reader.dart';
import 'document_handler.dart';

class PdfHandler extends DocumentHandler {
  @override
  String get id => 'pdf';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) {
    if (ref.extension == 'pdf') return true;
    if (headerBytes != null && headerBytes.length >= 4) {
      return headerBytes[0] == 0x25 && // %PDF
          headerBytes[1] == 0x50 &&
          headerBytes[2] == 0x44 &&
          headerBytes[3] == 0x46;
    }
    return false;
  }

  @override
  Future<Widget> buildReader(DocumentRef ref) async => PdfReader(ref: ref);

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async {
    final doc = await PdfDocument.openFile(ref.path);
    try {
      final page = await doc.getPage(1);
      try {
        final image = await page.render(
          width: 256,
          height: (256 * page.height / page.width).round().toDouble(),
          format: PdfPageImageFormat.jpeg,
        );
        if (image == null) return null;
        return Thumbnail(
          Uint8List.fromList(image.bytes),
          width: image.width,
          height: image.height,
        );
      } finally {
        await page.close();
      }
    } finally {
      await doc.close();
    }
  }

  /// pdfx does not expose text extraction; PDF search relies on filename
  /// matches only until a Phase 3 server-side or native solution lands.
  @override
  Future<String?> extractText(DocumentRef ref) async => null;
}
