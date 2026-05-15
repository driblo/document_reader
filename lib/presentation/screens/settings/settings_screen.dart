import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.settingsLanguage),
            onTap: () => context.go(AppRoutes.language),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: Text(l10n.settingsSupportLink),
            onTap: () => context.go(AppRoutes.support),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsOpenSourceLicenses),
            onTap: () => context.go(AppRoutes.licenses),
          ),
        ],
      ),
    );
  }
}
