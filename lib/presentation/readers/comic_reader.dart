import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../domain/document.dart';

/// CBZ reader: a comic archive is just a ZIP of images sorted by name.
/// CBR (RAR) needs `unrar` natively and is intentionally out of scope.
class ComicReader extends StatefulWidget {
  const ComicReader({super.key, required this.ref});
  final DocumentRef ref;

  @override
  State<ComicReader> createState() => _ComicReaderState();
}

class _ComicReaderState extends State<ComicReader> {
  late final Future<List<Uint8List>> _pages;

  @override
  void initState() {
    super.initState();
    _pages = _extract();
  }

  Future<List<Uint8List>> _extract() async {
    final bytes = await File(widget.ref.path).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final imageFiles = archive
        .where((f) => f.isFile && _isImage(f.name))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return [
      for (final f in imageFiles) Uint8List.fromList(f.content as List<int>),
    ];
  }

  bool _isImage(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Uint8List>>(
      future: _pages,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final pages = snap.data ?? const <Uint8List>[];
        if (pages.isEmpty) {
          return const Center(child: Text('Empty archive'));
        }
        return PhotoViewGallery.builder(
          itemCount: pages.length,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          builder: (_, i) => PhotoViewGalleryPageOptions(
            imageProvider: MemoryImage(pages[i]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
          ),
          loadingBuilder: (_, __) =>
              const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
