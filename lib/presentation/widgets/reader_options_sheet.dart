import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/reader_preferences_provider.dart';
import '../../domain/reader_preferences.dart';
import '../../l10n/app_localizations.dart';

/// Bottom sheet shown from the reader app bar. Lets the user pick a
/// reading theme, font family, and size. The reader widget rebuilds
/// automatically because it watches [readerPreferencesProvider].
class ReaderOptionsSheet extends ConsumerWidget {
  const ReaderOptionsSheet({super.key, this.showEncodingPicker = false});

  /// Text-style handlers (plain text, code) expose an encoding override;
  /// PDF/EPUB/image do not.
  final bool showEncodingPicker;

  static Future<void> show(
    BuildContext context, {
    bool showEncodingPicker = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => ReaderOptionsSheet(showEncodingPicker: showEncodingPicker),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(readerPreferencesProvider);
    final ctrl = ref.read(readerPreferencesProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.readerActions, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            _Section(label: l10n.readerThemeLight),
            SegmentedButton<ReaderTheme>(
              segments: [
                ButtonSegment(value: ReaderTheme.light, label: Text(l10n.readerThemeLight)),
                ButtonSegment(value: ReaderTheme.sepia, label: Text(l10n.readerThemeSepia)),
                ButtonSegment(value: ReaderTheme.dark, label: Text(l10n.readerThemeDark)),
                ButtonSegment(value: ReaderTheme.oledBlack, label: Text(l10n.readerThemeBlack)),
              ],
              selected: {prefs.theme},
              onSelectionChanged: (s) => ctrl.setTheme(s.first),
            ),
            const SizedBox(height: 16),
            _Section(label: l10n.readerFontFamily),
            SegmentedButton<ReaderFontFamily>(
              segments: [
                ButtonSegment(value: ReaderFontFamily.serif, label: Text(l10n.readerFontSerif)),
                ButtonSegment(value: ReaderFontFamily.sans, label: Text(l10n.readerFontSans)),
                ButtonSegment(value: ReaderFontFamily.mono, label: Text(l10n.readerFontMono)),
              ],
              selected: {prefs.fontFamily},
              onSelectionChanged: (s) => ctrl.setFont(s.first),
            ),
            const SizedBox(height: 16),
            _Section(label: l10n.readerFontSize),
            Slider(
              value: prefs.fontSize.clamp(10, 32),
              min: 10,
              max: 32,
              divisions: 22,
              label: prefs.fontSize.toStringAsFixed(0),
              onChanged: (v) => ctrl.setSize(v),
            ),
            if (showEncodingPicker) ...[
              const SizedBox(height: 8),
              _Section(label: l10n.readerEncoding),
              DropdownButton<String?>(
                value: prefs.encoding,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.readerEncodingAuto)),
                  for (final enc in const ['utf-8', 'utf-16', 'iso-8859-1', 'iso-8859-2', 'windows-1250', 'windows-1252'])
                    DropdownMenuItem(value: enc, child: Text(enc)),
                ],
                onChanged: (v) => ctrl.setEncoding(v),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
