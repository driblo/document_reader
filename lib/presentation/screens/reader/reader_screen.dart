import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../application/document_opener.dart';
import '../../../application/providers/handler_providers.dart';
import '../../../application/providers/persistence_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/routing/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../readers/image_reader.dart';
import '../../widgets/reader_options_sheet.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.filePath});
  final String filePath;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late final Future<OpenedDocument> _opened;

  @override
  void initState() {
    super.initState();
    _opened = _openAndRecord();
  }

  Future<OpenedDocument> _openAndRecord() async {
    final opener = ref.read(documentOpenerProvider);
    final result = await opener.open(widget.filePath);
    // Fire-and-forget: record this open, generate a thumbnail, and
    // (re)index the document for search. Failures are non-fatal — the
    // reader has already loaded.
    () async {
      final recents = ref.read(recentFilesServiceProvider);
      await recents.recordOpen(result.ref, handlerId: result.handler.id);
      final thumb = await result.handler.generateThumbnail(result.ref);
      if (thumb != null) await recents.saveThumbnail(result.ref.path, thumb.bytes);
      await ref.read(searchServiceProvider).indexDocument(result.ref);
    }();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<OpenedDocument>(
      future: _opened,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.readerLoading)),
          );
        }
        final error = snap.error;
        if (error != null) {
          return Scaffold(
            appBar: AppBar(title: Text(_titleFromPath(widget.filePath))),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_messageFor(error, l10n)),
              ),
            ),
          );
        }
        final opened = snap.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(opened.ref.displayName),
            actions: [
              IconButton(
                tooltip: l10n.readerBookmarks,
                icon: const Icon(Icons.bookmark_outline),
                onPressed: () => context.go(
                  '${AppRoutes.bookmarks}?path='
                  '${Uri.encodeQueryComponent(opened.ref.path)}',
                ),
              ),
              if (opened.handler.id == 'image')
                IconButton(
                  tooltip: l10n.readerOcrAction,
                  icon: const Icon(Icons.text_fields_outlined),
                  onPressed: () => showOcrDialog(context, opened.ref.path),
                ),
              if (_isTextual(opened.handler.id))
                IconButton(
                  tooltip: l10n.readerSpeakStart,
                  icon: const Icon(Icons.record_voice_over_outlined),
                  onPressed: () => _toggleTts(opened),
                ),
              IconButton(
                tooltip: l10n.readerActions,
                icon: const Icon(Icons.tune),
                onPressed: () => ReaderOptionsSheet.show(
                  context,
                  showEncodingPicker: opened.handler.id == 'text' ||
                      opened.handler.id == 'code',
                ),
              ),
              PopupMenuButton<_Overflow>(
                onSelected: (v) => _onOverflow(v, opened),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: _Overflow.share,
                    child: Text(l10n.share),
                  ),
                  if (opened.handler.id == 'pdf')
                    PopupMenuItem(
                      value: _Overflow.print,
                      child: Text(l10n.readerPrint),
                    ),
                ],
              ),
            ],
          ),
          body: opened.reader,
        );
      },
    );
  }

  bool _isTextual(String handlerId) =>
      handlerId == 'text' ||
      handlerId == 'markdown' ||
      handlerId == 'code' ||
      handlerId == 'html' ||
      handlerId == 'epub';

  Future<void> _toggleTts(OpenedDocument opened) async {
    final tts = ref.read(textToSpeechProvider);
    if (tts.isSpeaking) {
      await tts.stop();
      return;
    }
    final text = await opened.handler.extractText(opened.ref);
    if (text == null || text.isEmpty || !mounted) return;
    await tts.speak(text);
  }

  Future<void> _onOverflow(_Overflow choice, OpenedDocument opened) async {
    switch (choice) {
      case _Overflow.share:
        await Share.shareXFiles([XFile(opened.ref.path)]);
      case _Overflow.print:
        await Printing.layoutPdf(
          onLayout: (_) async => File(opened.ref.path).readAsBytes(),
          name: opened.ref.displayName,
        );
    }
  }

  String _titleFromPath(String path) {
    final i = path.lastIndexOf('/');
    return i == -1 ? path : path.substring(i + 1);
  }

  String _messageFor(Object error, AppLocalizations l10n) {
    return switch (error) {
      FileMissingException() => l10n.errorFileMissing,
      PermissionDeniedException() => l10n.errorPermissionDenied,
      UnsupportedFormatException() => l10n.readerUnsupported,
      ReaderFailureException() => l10n.readerOpenFailed,
      _ => l10n.errorGeneric,
    };
  }
}

enum _Overflow { share, print }
