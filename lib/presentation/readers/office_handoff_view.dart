import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../domain/document.dart';
import '../../l10n/app_localizations.dart';

/// "Quick preview — open in another app for full formatting" pattern from
/// the plan §6.5. Used for the Phase 2 office formats where Flutter has
/// no good native renderer; defers to the OS handler via the share /
/// open-with intent.
class OfficeHandoffView extends StatelessWidget {
  const OfficeHandoffView({super.key, required this.ref});
  final DocumentRef ref;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            ref.displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.readerHandoffNotice,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.readerHandoffAction),
            onPressed: () => OpenFilex.open(ref.path, type: ref.mimeType),
          ),
        ],
      ),
    );
  }
}
