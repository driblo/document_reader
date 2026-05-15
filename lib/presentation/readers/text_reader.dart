import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reader_preferences_provider.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/document.dart';
import '../../infrastructure/text/charset_decoder.dart';

class TextReader extends ConsumerStatefulWidget {
  const TextReader({super.key, required this.ref});
  final DocumentRef ref;

  @override
  ConsumerState<TextReader> createState() => _TextReaderState();
}

class _TextReaderState extends ConsumerState<TextReader> {
  late final Future<({String text, String encoding})> _loaded;

  @override
  void initState() {
    super.initState();
    _loaded = _readFile();
  }

  Future<({String text, String encoding})> _readFile() async {
    final file = File(widget.ref.path);
    if (!file.existsSync()) {
      throw const FileMissingException('File no longer exists.');
    }
    final bytes = await file.readAsBytes();
    final preferred = ref.read(readerPreferencesProvider).encoding;
    return const CharsetDecoder().decode(bytes, preferredEncoding: preferred);
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(readerPreferencesProvider);
    return FutureBuilder<({String text, String encoding})>(
      future: _loaded,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text(snap.error.toString()));
        }
        final data = snap.data!;
        return Container(
          color: prefs.backgroundColor,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: SelectableText(
              data.text,
              style: TextStyle(
                color: prefs.foregroundColor,
                fontSize: prefs.fontSize,
                fontFamily: prefs.fontFamilyName,
                height: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
