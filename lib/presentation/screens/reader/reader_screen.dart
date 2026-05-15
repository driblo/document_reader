import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/handler_providers.dart';
import '../../../core/errors/app_exception.dart';
import '../../../l10n/app_localizations.dart';

class ReaderScreen extends ConsumerWidget {
  const ReaderScreen({super.key, required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final opener = ref.watch(documentOpenerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_titleFromPath(filePath))),
      body: FutureBuilder<Widget>(
        future: opener.open(filePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: Text(l10n.readerLoading));
          }
          final error = snapshot.error;
          if (error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_messageFor(error, l10n)),
              ),
            );
          }
          return snapshot.data ?? const SizedBox.shrink();
        },
      ),
    );
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
