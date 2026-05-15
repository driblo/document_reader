# Document Reader

Universal document reader for Android and iOS, built with Flutter. The
full design lives in [`plan.md`](./plan.md); this README only covers
what is wired up today and what is intentionally still empty.

## Status — end of Phase 0 scaffolding

What is in the tree:

- `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`,
  `flutter_native_splash.yaml`
- 25-locale ARB scaffold under `lib/l10n/` (English populated, others
  copied verbatim — translate iteratively per plan §3.1)
- Material 3 theme, edge-to-edge system UI (no `immersive*` mode), and
  a `go_router` skeleton
- Riverpod providers for locale, theme mode, handler registry, document
  opener and recents
- Domain model: `DocumentRef`, `Bookmark`, `Annotation`, `ReaderState`
- `DocumentHandler` strategy + `HandlerRegistry` plus stub handlers for
  every Tier A format and the Tier B office handoff
- Drift schema for `documents`, `recents`, `bookmarks`, `reader_states`
  and an FTS5 search index (generated bindings build with
  `dart run build_runner build`)
- Mandatory settings screens: Language, Support our work, Open source
  licenses (`showLicensePage()` wrapper)
- Smoke test for the handler registry

What is **not** yet done:

- Real renderers — every handler currently returns the stub widget from
  `lib/infrastructure/handlers/_stub.dart`. Phase 1 fills these in.
- Splash slogan — `splashSlogan` ARB key is intentionally empty,
  blocking on product copy (plan §7.1).
- Translations — only English is meaningful; all other ARB files are
  copies of the English template.
- Native platform projects (`android/`, `ios/`) — not generated here
  since `flutter create` was not available in the bootstrap
  environment. Run `flutter create . --platforms=android,ios` to add
  them, then `flutter pub get` and
  `dart run build_runner build --delete-conflicting-outputs`.

## Bootstrap

```bash
flutter create . --platforms=android,ios   # one time, generates native shells
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Layout

See plan.md §4 for the full layered breakdown. In short:

```
lib/
  core/           theme · routing · lifecycle · errors
  domain/         pure-Dart models
  infrastructure/ handlers · mime · database · prefs · filesystem
  application/    document opener · services · Riverpod providers
  presentation/   screens · widgets
  l10n/           ARB files + supported locales list
```
