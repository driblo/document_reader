import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/handlers/handler_registry.dart';
import '../document_opener.dart';
import '../recent_files_service.dart';

final handlerRegistryProvider =
    Provider<HandlerRegistry>((_) => HandlerRegistry.defaults());

final documentOpenerProvider = Provider<DocumentOpener>((ref) {
  return DocumentOpener(registry: ref.watch(handlerRegistryProvider));
});

final recentFilesProvider =
    Provider<RecentFilesService>((_) => InMemoryRecentFilesService());
