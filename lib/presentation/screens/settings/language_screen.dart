import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/settings_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/supported_locales.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageScreenTitle)),
      body: ListView(
        children: [
          RadioListTile<Locale?>(
            title: Text(l10n.languageSystemDefault),
            value: null,
            groupValue: selected,
            onChanged: (v) => ref.read(localeProvider.notifier).state = v,
          ),
          const Divider(height: 1),
          // kSupportedLocales is already alphabetical by English display name.
          for (final locale in kSupportedLocales)
            RadioListTile<Locale?>(
              title: Text(kLocaleDisplayNames[locale.languageCode]!),
              value: locale,
              groupValue: selected,
              onChanged: (v) => ref.read(localeProvider.notifier).state = v,
            ),
        ],
      ),
    );
  }
}
