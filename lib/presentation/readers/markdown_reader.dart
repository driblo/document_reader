import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../../application/providers/reader_preferences_provider.dart';
import '../../domain/document.dart';

class MarkdownReader extends ConsumerWidget {
  const MarkdownReader({super.key, required this.ref});
  final DocumentRef ref;

  @override
  Widget build(BuildContext context, WidgetRef wref) {
    final prefs = wref.watch(readerPreferencesProvider);
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
          return Markdown(
            data: snap.data ?? '',
            selectable: true,
            padding: const EdgeInsets.all(16),
            extensionSet: md.ExtensionSet.gitHubFlavored,
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                color: prefs.foregroundColor,
                fontSize: prefs.fontSize,
                fontFamily: prefs.fontFamilyName,
                height: 1.5,
              ),
              h1: TextStyle(color: prefs.foregroundColor, fontSize: prefs.fontSize * 1.8),
              h2: TextStyle(color: prefs.foregroundColor, fontSize: prefs.fontSize * 1.5),
              h3: TextStyle(color: prefs.foregroundColor, fontSize: prefs.fontSize * 1.25),
              code: TextStyle(
                fontFamily: 'monospace',
                fontSize: prefs.fontSize * 0.95,
                color: prefs.foregroundColor,
                backgroundColor: prefs.backgroundColor.withOpacity(0.6),
              ),
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: prefs.foregroundColor.withOpacity(0.3), width: 4),
                ),
              ),
            ),
            onTapLink: (text, href, title) async {
              if (href == null) return;
              final uri = Uri.tryParse(href);
              if (uri != null) await launchUrl(uri);
            },
          );
        },
      ),
    );
  }
}
