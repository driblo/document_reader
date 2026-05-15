import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../domain/document.dart';
import '../../presentation/readers/image_reader.dart';
import 'document_handler.dart';

class ImageHandler extends DocumentHandler {
  static const _exts = {
    'jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic', 'heif', 'tiff', 'tif',
  };

  @override
  String get id => 'image';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);

  @override
  Future<Widget> buildReader(DocumentRef ref) async => ImageReader(ref: ref);

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async {
    final src = File(ref.path);
    if (!src.existsSync()) return null;
    final bytes = await FlutterImageCompress.compressWithFile(
      src.path,
      minWidth: 256,
      minHeight: 256,
      quality: 80,
      format: CompressFormat.jpeg,
    );
    if (bytes == null) return null;
    return Thumbnail(Uint8List.fromList(bytes));
  }

  @override
  Future<String?> extractText(DocumentRef ref) async => null;
}
