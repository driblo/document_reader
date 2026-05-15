import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../application/providers/reader_preferences_provider.dart';
import '../../domain/document.dart';

class HtmlReader extends ConsumerWidget {
  const HtmlReader({super.key, required this.ref});
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Html(
              data: snap.data ?? '',
              style: {
                'body': Style(
                  color: prefs.foregroundColor,
                  fontSize: FontSize(prefs.fontSize),
                  fontFamily: prefs.fontFamilyName,
                  lineHeight: const LineHeight(1.5),
                ),
              },
              onLinkTap: (url, attrs, element) async {
                if (url == null) return;
                final uri = Uri.tryParse(url);
                if (uri != null) await launchUrl(uri);
              },
            ),
          );
        },
      ),
    );
  }
}
