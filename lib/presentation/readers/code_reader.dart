import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reader_preferences_provider.dart';
import '../../domain/document.dart';
import '../../domain/reader_preferences.dart';

class CodeReader extends ConsumerWidget {
  const CodeReader({super.key, required this.ref});
  final DocumentRef ref;

  @override
  Widget build(BuildContext context, WidgetRef wref) {
    final prefs = wref.watch(readerPreferencesProvider);
    final language = _languageFromExtension(ref.extension);
    final theme = switch (prefs.theme) {
      ReaderTheme.light || ReaderTheme.sepia => atomOneLightTheme,
      ReaderTheme.dark || ReaderTheme.oledBlack => atomOneDarkTheme,
    };

    return Container(
      color: prefs.backgroundColor,
      child: FutureBuilder<String>(
        future: File(ref.path).readAsString(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text(snap.error.toString()));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HighlightView(
                snap.data ?? '',
                language: language,
                theme: theme,
                padding: const EdgeInsets.all(12),
                textStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: prefs.fontSize,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _languageFromExtension(String ext) {
    return switch (ext) {
      'dart' => 'dart',
      'java' => 'java',
      'kt' || 'kts' => 'kotlin',
      'swift' => 'swift',
      'm' || 'mm' => 'objectivec',
      'c' || 'h' => 'c',
      'cc' || 'cpp' || 'hpp' || 'cxx' => 'cpp',
      'cs' => 'cs',
      'go' => 'go',
      'rs' => 'rust',
      'rb' => 'ruby',
      'py' => 'python',
      'php' => 'php',
      'pl' => 'perl',
      'lua' => 'lua',
      'sh' || 'bash' || 'zsh' => 'bash',
      'js' || 'mjs' || 'cjs' => 'javascript',
      'ts' || 'tsx' => 'typescript',
      'jsx' => 'javascript',
      'json' => 'json',
      'yaml' || 'yml' => 'yaml',
      'toml' => 'ini',
      'xml' => 'xml',
      'sql' => 'sql',
      'r' => 'r',
      'scala' => 'scala',
      'groovy' => 'groovy',
      _ => 'plaintext',
    };
  }
}
