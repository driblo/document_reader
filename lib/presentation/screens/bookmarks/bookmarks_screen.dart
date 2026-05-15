import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/providers/persistence_providers.dart';
import '../../../domain/bookmark.dart';
import '../../../l10n/app_localizations.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key, required this.documentPath});
  final String documentPath;

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  late Future<List<Bookmark>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref
        .read(bookmarksServiceProvider)
        .listFor(widget.documentPath);
  }

  void _reload() {
    setState(() {
      _future = ref
          .read(bookmarksServiceProvider)
          .listFor(widget.documentPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.readerBookmarks)),
      body: FutureBuilder<List<Bookmark>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? const <Bookmark>[];
          if (items.isEmpty) {
            return Center(child: Text(l10n.readerNoBookmarks));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final b = items[i];
              return ListTile(
                title: Text(b.label),
                subtitle: Text(b.position),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref
                        .read(bookmarksServiceProvider)
                        .remove(b.id);
                    _reload();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
