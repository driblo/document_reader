import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:photo_view/photo_view.dart';

import '../../domain/document.dart';
import '../../l10n/app_localizations.dart';

class ImageReader extends StatefulWidget {
  const ImageReader({super.key, required this.ref});
  final DocumentRef ref;

  @override
  State<ImageReader> createState() => _ImageReaderState();
}

class _ImageReaderState extends State<ImageReader> {
  late Future<File> _imageFile;

  @override
  void initState() {
    super.initState();
    _imageFile = _prepare();
  }

  /// On Android the native HEIC decoder is patchy below API 30; transcode
  /// to JPEG up front so PhotoView's `FileImage` provider can always
  /// open the bytes.
  Future<File> _prepare() async {
    final src = File(widget.ref.path);
    final ext = widget.ref.extension;
    if (Platform.isAndroid && (ext == 'heic' || ext == 'heif')) {
      final out = '${src.path}.transcoded.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        src.path,
        out,
        format: CompressFormat.jpeg,
        quality: 90,
      );
      if (result != null) return File(result.path);
    }
    return src;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _imageFile,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text(snap.error.toString()));
        }
        return PhotoView(
          imageProvider: FileImage(snap.data!),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        );
      },
    );
  }
}

/// Phase 3 OCR helper. Triggered from the reader app bar's overflow menu.
Future<String?> recognizeTextFromImage(String path) async {
  final recognizer = TextRecognizer();
  try {
    final input = InputImage.fromFilePath(path);
    final result = await recognizer.processImage(input);
    final trimmed = result.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  } finally {
    await recognizer.close();
  }
}

Future<void> showOcrDialog(BuildContext context, String imagePath) async {
  final l10n = AppLocalizations.of(context);
  final text = await recognizeTextFromImage(imagePath);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(l10n.readerOcrAction),
      content: SingleChildScrollView(
        child: SelectableText(text ?? l10n.readerOcrEmpty),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
      ],
    ),
  );
}
