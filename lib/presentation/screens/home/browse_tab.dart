import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';

import '../../../application/providers/scanner_providers.dart';
import '../../../core/routing/app_router.dart';
import '../../../domain/document.dart';
import '../../../domain/fs_entry.dart';
import '../../../infrastructure/handlers/handler_registry.dart';

/// Drives the folder stack for [BrowseTab] and lets [HomeScreen] hook the
/// Android back button into "go up a folder" instead of leaving the app.
class BrowseNavController extends ChangeNotifier {
  final List<BrowseCrumb> _stack = [];

  bool get canGoUp => _stack.isNotEmpty;
  List<BrowseCrumb> get stack => List.unmodifiable(_stack);
  String? get currentPath => _stack.isEmpty ? null : _stack.last.path;

  void open(String path, String label) {
    _stack.add(BrowseCrumb(path, label));
    notifyListeners();
  }

  void goUp() {
    if (_stack.isEmpty) return;
    _stack.removeLast();
    notifyListeners();
  }

  void goTo(int index) {
    if (index < -1 || index >= _stack.length - 1) return;
    _stack.removeRange(index + 1, _stack.length);
    notifyListeners();
  }
}

class BrowseCrumb {
  const BrowseCrumb(this.path, this.label);
  final String path;
  final String label;
}

/// A folder browser like a system Files app: navigate into real device
/// folders (not just this app's recursive document index) and open
/// anything supported directly, or hand unsupported files to the OS.
class BrowseTab extends ConsumerWidget {
  const BrowseTab({super.key, required this.nav});
  final BrowseNavController nav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: nav,
      builder: (context, _) {
        return Column(
          children: [
            _Breadcrumbs(nav: nav),
            const Divider(height: 1),
            Expanded(
              child: nav.currentPath == null
                  ? _VolumesList(nav: nav)
                  : _FolderList(path: nav.currentPath!, nav: nav),
            ),
          ],
        );
      },
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.nav});
  final BrowseNavController nav;

  @override
  Widget build(BuildContext context) {
    final crumbs = nav.stack;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Up',
            onPressed: nav.canGoUp ? nav.goUp : null,
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _CrumbChip(
                  label: 'Storage',
                  onTap: crumbs.isEmpty ? null : () => nav.goTo(-1),
                ),
                for (var i = 0; i < crumbs.length; i++) ...[
                  const Icon(Icons.chevron_right, size: 18),
                  _CrumbChip(
                    label: crumbs[i].label,
                    onTap: i == crumbs.length - 1 ? null : () => nav.goTo(i),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CrumbChip extends StatelessWidget {
  const _CrumbChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = onTap == null;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
          ),
        ),
      ),
    );
  }
}

class _VolumesList extends ConsumerWidget {
  const _VolumesList({required this.nav});
  final BrowseNavController nav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(storageVolumesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(storageVolumesProvider),
      ),
      data: (volumes) {
        if (volumes.isEmpty) {
          return const _ErrorState(
            message: 'No accessible storage found.',
            onRetry: null,
          );
        }
        return ListView.separated(
          itemCount: volumes.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final v = volumes[i];
            return ListTile(
              leading: const Icon(Icons.sd_storage_outlined),
              title: Text(v.label),
              subtitle: Text(v.path, style: Theme.of(context).textTheme.bodySmall),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => nav.open(v.path, v.label),
            );
          },
        );
      },
    );
  }
}

class _FolderList extends ConsumerWidget {
  const _FolderList({required this.path, required this.nav});
  final String path;
  final BrowseNavController nav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = folderListingProvider(path);
    final async = ref.watch(provider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(provider),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const _ErrorState(message: 'This folder is empty.', onRetry: null);
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(provider);
            await ref.read(provider.future);
          },
          child: ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _EntryRow(entry: entries[i], nav: nav),
          ),
        );
      },
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.nav});
  final FsEntry entry;
  final BrowseNavController nav;

  bool get _supported {
    if (entry.isDirectory) return false;
    final ref = DocumentRef(
      path: entry.path,
      displayName: entry.name,
      mimeType: 'application/octet-stream',
      sizeBytes: entry.sizeBytes ?? 0,
    );
    return HandlerRegistry.defaults().resolve(ref) != null;
  }

  @override
  Widget build(BuildContext context) {
    if (entry.isDirectory) {
      return ListTile(
        leading: const Icon(Icons.folder_outlined),
        title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => nav.open(entry.path, entry.name),
      );
    }

    final supported = _supported;
    return ListTile(
      leading: Icon(_iconFor(entry.extension)),
      title: Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        _subtitle(entry),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: supported
          ? null
          : Icon(
              Icons.open_in_new,
              size: 18,
              color: Theme.of(context).colorScheme.outline,
            ),
      onTap: () {
        if (supported) {
          context.push(
            '${AppRoutes.reader}?path=${Uri.encodeQueryComponent(entry.path)}',
          );
        } else {
          OpenFilex.open(entry.path);
        }
      },
    );
  }

  String _subtitle(FsEntry f) {
    final parts = <String>[];
    if (f.lastModified != null) {
      final d = f.lastModified!;
      parts.add('${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
    }
    if (f.sizeBytes != null) parts.add(_sizeLabel(f.sizeBytes!));
    return parts.join(' · ');
  }

  String _sizeLabel(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

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
        'mp3' || 'wav' || 'm4a' || 'flac' || 'ogg' => Icons.audiotrack_outlined,
        'mp4' || 'mkv' || 'mov' || 'avi' || 'webm' => Icons.movie_outlined,
        'apk' => Icons.android_outlined,
        'zip' || 'rar' || '7z' || 'tar' || 'gz' => Icons.folder_zip_outlined,
        '' => Icons.insert_drive_file_outlined,
        _ => Icons.code,
      };
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
