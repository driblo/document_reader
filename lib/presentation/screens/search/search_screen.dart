import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/providers/persistence_providers.dart';
import '../../../application/services/search_service.dart';
import '../../../core/routing/app_router.dart';
import '../../../l10n/app_localizations.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Future<List<SearchHit>>? _pending;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSearch(String q) {
    final service = ref.read(searchServiceProvider);
    setState(() => _pending = service.search(q));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _runSearch,
        ),
      ),
      body: _pending == null
          ? Center(child: Text(l10n.searchHint))
          : FutureBuilder<List<SearchHit>>(
              future: _pending,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final hits = snap.data ?? const <SearchHit>[];
                if (hits.isEmpty) {
                  return Center(child: Text(l10n.searchNoResults));
                }
                return ListView.separated(
                  itemCount: hits.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final h = hits[i];
                    return ListTile(
                      title: Text(
                        h.documentPath.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(h.snippet,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Text(h.score.toStringAsFixed(1)),
                      onTap: () => context.go(
                        '${AppRoutes.reader}?path='
                        '${Uri.encodeQueryComponent(h.documentPath)}',
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
