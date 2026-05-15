import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/bookmarks/bookmarks_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/reader/reader_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/settings/language_screen.dart';
import '../../presentation/screens/settings/licenses_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/support_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const reader = '/reader';
  static const bookmarks = '/bookmarks';
  static const search = '/search';
  static const settings = '/settings';
  static const language = '/settings/language';
  static const support = '/settings/support';
  static const licenses = '/settings/licenses';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.reader,
        builder: (_, state) {
          final path = state.uri.queryParameters['path'] ?? '';
          return ReaderScreen(filePath: path);
        },
      ),
      GoRoute(
        path: AppRoutes.bookmarks,
        builder: (_, state) {
          final path = state.uri.queryParameters['path'] ?? '';
          return BookmarksScreen(documentPath: path);
        },
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (_, __) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'language',
            builder: (_, __) => const LanguageScreen(),
          ),
          GoRoute(
            path: 'support',
            builder: (_, __) => const SupportScreen(),
          ),
          GoRoute(
            path: 'licenses',
            builder: (_, __) => const LicensesScreen(),
          ),
        ],
      ),
    ],
  );
});
