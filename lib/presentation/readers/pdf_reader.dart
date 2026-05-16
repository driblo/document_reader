import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../../application/providers/persistence_providers.dart';
import '../../domain/document.dart';
import '../../l10n/app_localizations.dart';

class PdfReader extends ConsumerStatefulWidget {
  const PdfReader({super.key, required this.ref});
  final DocumentRef ref;

  @override
  ConsumerState<PdfReader> createState() => PdfReaderState();
}

class PdfReaderState extends ConsumerState<PdfReader> {
  late final PdfController _controller;
  int _current = 1;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _controller = PdfController(
      document: PdfDocument.openFile(widget.ref.path),
      initialPage: 1,
    );
    _restorePosition();
  }

  Future<void> _restorePosition() async {
    final saved = await ref
        .read(readerStatesServiceProvider)
        .load(widget.ref.path);
    if (saved == null) return;
    final page = int.tryParse(saved.position);
    if (page != null && page > 1) {
      await _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  /// Called by the [ReaderScreen] before the user navigates away so the
  /// page survives an app kill.
  Future<void> savePosition() {
    return ref.read(readerStatesServiceProvider).save(
          widget.ref.path,
          position: _current.toString(),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        PdfView(
          controller: _controller,
          onDocumentLoaded: (doc) => setState(() => _total = doc.pagesCount),
          onPageChanged: (page) => setState(() => _current = page),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Center(
            child: Material(
              color: Colors.black.withOpacity(0.6),
              shape: const StadiumBorder(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Text(
                  _total == 0
                      ? l10n.readerLoading
                      : l10n.readerPagePosition(_current, _total),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
