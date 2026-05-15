import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../application/providers/persistence_providers.dart';
import '../../../core/routing/app_router.dart';
import '../../../domain/document.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamSubscription<List<SharedMediaFile>>? _shareSub;

  @override
  void initState() {
    super.initState();
    _wireShareIntents();
  }

  void _wireShareIntents() {
    // Cold-start case: a file was passed in when the app launched.
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) _openShared(files.first.path);
    });
    // Hot case: app is already running.
    _shareSub = ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      if (files.isNotEmpty) _openShared(files.first.path);
    });
  }

  void _openShared(String path) {
    if (!mounted) return;
    context.go('${AppRoutes.reader}?path=${Uri.encodeQueryComponent(path)}');
  }

  @override
  void dispose() {
    _shareSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final recents = ref.watch(recentFilesServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(AppRoutes.search),
            tooltip: l10n.search,
          ),
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
              return _RecentRow(ref: r);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.folder_open_outlined),
        label: Text(l10n.homeBrowse),
        onPressed: () => _pickAndOpen(context),
      ),
    );
  }

  Future<void> _pickAndOpen(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final path = result.files.single.path;
    if (path == null || !context.mounted) return;
    context.go('${AppRoutes.reader}?path=${Uri.encodeQueryComponent(path)}');
  }
}

class _RecentRow extends ConsumerWidget {
  const _RecentRow({required this.ref});
  final DocumentRef ref;

  @override
  Widget build(BuildContext context, WidgetRef wref) {
    final recents = wref.watch(recentFilesServiceProvider);
    return ListTile(
      leading: FutureBuilder<List<int>?>(
        future: recents.loadThumbnail(ref.path),
        builder: (_, snap) {
          final bytes = snap.data;
          if (bytes == null) {
            return const Icon(Icons.description_outlined, size: 40);
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.memory(
              Uint8List.fromList(bytes),
              width: 40,
              height: 56,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
      title: Text(ref.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(ref.path, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () => context.go(
        '${AppRoutes.reader}?path=${Uri.encodeQueryComponent(ref.path)}',
      ),
    );
  }
}
