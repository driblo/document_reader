import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../../application/providers/persistence_providers.dart';
import '../../../application/providers/scanner_providers.dart';
import '../../../core/routing/app_router.dart';
import '../../../domain/document.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<List<SharedMediaFile>>? _shareSub;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _wireShareIntents();
  }

  void _wireShareIntents() {
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) _openShared(files.first.path);
    });
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
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: 'Recents'),
            Tab(icon: Icon(Icons.folder_outlined), text: 'Library'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _RecentsTab(onPick: () => _pickAndOpen(context)),
          const _LibraryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.homeBrowse,
        onPressed: () => _pickAndOpen(context),
        child: const Icon(Icons.folder_open_outlined),
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

// ── Recents tab ────────────────────────────────────────────────────────────────

class _RecentsTab extends ConsumerWidget {
  const _RecentsTab({required this.onPick});
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final recents = ref.watch(recentFilesServiceProvider);
    return FutureBuilder<List<DocumentRef>>(
      future: recents.list(),
      builder: (context, snap) {
        final items = snap.data ?? const <DocumentRef>[];
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
          itemBuilder: (_, i) => _RecentRow(ref: items[i]),
        );
      },
    );
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
            return Icon(_iconFor(ref.extension), size: 40);
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
      subtitle: Text(
        ref.path,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () => context.go(
        '${AppRoutes.reader}?path=${Uri.encodeQueryComponent(ref.path)}',
      ),
    );
  }
}

// ── Library tab ────────────────────────────────────────────────────────────────

class _LibraryTab extends ConsumerWidget {
  const _LibraryTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(libraryFilesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(libraryFilesProvider),
      ),
      data: (files) {
        if (files.isEmpty) {
          return _EmptyLibrary(onRetry: () => ref.invalidate(libraryFilesProvider));
        }
        return _FileList(files: files, onRefresh: () {
          ref.invalidate(libraryFilesProvider);
          return ref.read(libraryFilesProvider.future);
        });
      },
    );
  }
}

class _FileList extends StatelessWidget {
  const _FileList({required this.files, required this.onRefresh});
  final List<DocumentRef> files;
  final Future<List<DocumentRef>> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        itemCount: files.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => _FileRow(file: files[i]),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file});
  final DocumentRef file;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            Theme.of(context).colorScheme.secondaryContainer,
        child: Icon(
          _iconFor(file.extension),
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          size: 22,
        ),
      ),
      title: Text(file.displayName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        _subtitle(file),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        file.extension.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      onTap: () => context.go(
        '${AppRoutes.reader}?path=${Uri.encodeQueryComponent(file.path)}',
      ),
    );
  }

  String _subtitle(DocumentRef f) {
    final parts = <String>[];
    if (f.lastModified != null) {
      final d = f.lastModified!;
      parts.add('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }
    parts.add(_sizeLabel(f.sizeBytes));
    // Show parent folder name
    final segments = f.path.replaceAll('\\', '/').split('/');
    if (segments.length >= 2) parts.add(segments[segments.length - 2]);
    return parts.join(' · ');
  }

  String _sizeLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_off_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No supported files found on this device.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Scan again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────────

IconData _iconFor(String ext) => switch (ext) {
      'pdf' => Icons.picture_as_pdf_outlined,
      'epub' => Icons.menu_book_outlined,
      'md' || 'markdown' || 'html' || 'htm' => Icons.article_outlined,
      'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' ||
          'bmp' || 'heic' || 'heif' || 'tiff' || 'tif' =>
        Icons.image_outlined,
      'cbz' || 'cbr' => Icons.auto_stories_outlined,
      'doc' || 'docx' || 'odt' => Icons.description_outlined,
      'xls' || 'xlsx' || 'ods' => Icons.table_chart_outlined,
      'ppt' || 'pptx' || 'odp' => Icons.slideshow_outlined,
      'txt' || 'csv' || 'log' => Icons.text_snippet_outlined,
      _ => Icons.code,
    };
