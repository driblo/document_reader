import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/handler_providers.dart';
import '../../../core/routing/app_router.dart';
import '../../../domain/document.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recents = ref.watch(recentFilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(AppRoutes.settings),
            tooltip: l10n.settingsTitle,
          ),
        ],
      ),
      body: FutureBuilder<List<DocumentRef>>(
        future: recents.list(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <DocumentRef>[];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.homeEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = items[i];
              return ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(r.displayName),
                subtitle: Text(r.path),
                onTap: () => context.go(
                  '${AppRoutes.reader}?path=${Uri.encodeQueryComponent(r.path)}',
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.folder_open_outlined),
        label: Text(l10n.homeBrowse),
        onPressed: () => _pickAndOpen(context, ref),
      ),
    );
  }

  Future<void> _pickAndOpen(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path;
    if (path == null || !context.mounted) return;
    context.go('${AppRoutes.reader}?path=${Uri.encodeQueryComponent(path)}');
  }
}
