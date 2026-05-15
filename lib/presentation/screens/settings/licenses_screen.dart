import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Wrapper around Flutter's built-in [showLicensePage]. The button title
/// itself goes through localization; the license bodies are kept in
/// their original English (legal text — translating it would change its
/// meaning).
class LicensesScreen extends StatelessWidget {
  const LicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LicensePage(
      applicationName: l10n.appName,
      applicationLegalese: '',
    );
  }
}
