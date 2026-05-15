import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Per the mandatory-features rule: tapping "Support our work" opens an
/// in-app screen (not a browser) with the localized headline. Concrete
/// donation/IAP wiring is filled in once the monetization decision is
/// made (see plan §7.3).
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsSupportLink)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.supportHeadline,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.supportBody,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: Text(l10n.supportActionDonate),
                onPressed: () {
                  // TODO: wire donation link / IAP once decided.
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.share_outlined),
                label: Text(l10n.supportActionShare),
                onPressed: () {
                  // TODO: invoke share sheet via share_plus once added.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
