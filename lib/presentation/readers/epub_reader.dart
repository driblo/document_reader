import 'dart:io';

import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/persistence_providers.dart';
import '../../application/providers/reader_preferences_provider.dart';
import '../../domain/document.dart';

class EpubReader extends ConsumerStatefulWidget {
  const EpubReader({super.key, required this.ref});
  final DocumentRef ref;

  @override
  ConsumerState<EpubReader> createState() => EpubReaderState();
}

class EpubReaderState extends ConsumerState<EpubReader> {
  late final EpubController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EpubController(
      document: EpubDocument.openFile(File(widget.ref.path)),
    );
    _restorePosition();
  }

  Future<void> _restorePosition() async {
    final saved =
        await ref.read(readerStatesServiceProvider).load(widget.ref.path);
    if (saved == null || saved.position.isEmpty) return;
    // EpubController uses CFI strings as locations.
    _controller.gotoEpubCfi(saved.position);
  }

  Future<void> savePosition() async {
    final cfi = _controller.generateEpubCfi();
    if (cfi == null) return;
    await ref.read(readerStatesServiceProvider).save(
          widget.ref.path,
          position: cfi,
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(readerPreferencesProvider);
    return Container(
      color: prefs.backgroundColor,
      child: EpubView(
        controller: _controller,
        builders: EpubViewBuilders<DefaultBuilderOptions>(
          options: DefaultBuilderOptions(
            textStyle: TextStyle(
              color: prefs.foregroundColor,
              fontSize: prefs.fontSize,
              fontFamily: prefs.fontFamilyName,
              height: 1.5,
            ),
          ),
          chapterDividerBuilder: (_) => Divider(
            color: prefs.foregroundColor.withOpacity(0.2),
          ),
        ),
      ),
    );
  }
}
