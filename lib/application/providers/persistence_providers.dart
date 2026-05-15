import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../infrastructure/database/app_database.dart';
import '../../infrastructure/tts/text_to_speech.dart';
import '../services/bookmarks_service.dart';
import '../services/reader_states_service.dart';
import '../services/recent_files_service.dart';
import '../services/search_service.dart';
import 'handler_providers.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final recentFilesServiceProvider = Provider<RecentFilesService>(
  (ref) => RecentFilesService(ref.watch(appDatabaseProvider)),
);

final bookmarksServiceProvider = Provider<BookmarksService>(
  (ref) => BookmarksService(ref.watch(appDatabaseProvider)),
);

final readerStatesServiceProvider = Provider<ReaderStatesService>(
  (ref) => ReaderStatesService(ref.watch(appDatabaseProvider)),
);

final searchServiceProvider = Provider<SearchService>(
  (ref) => SearchService(
    ref.watch(appDatabaseProvider),
    ref.watch(handlerRegistryProvider),
  ),
);

final textToSpeechProvider = Provider<TextToSpeech>((ref) {
  final tts = TextToSpeech();
  ref.onDispose(tts.dispose);
  return tts;
});
