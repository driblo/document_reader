# Document Reader

Universal document reader for Android and iOS, built with Flutter. The
full design lives in [`plan.md`](./plan.md); this README covers the
current implementation state.

## Status — Phases 0 / 1 / 2 / 3 wired in Dart

What works (assuming `flutter pub get` and `dart run build_runner build`
succeed on a real Flutter install):

**Phase 0 — scaffolding**

- `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`,
  `flutter_native_splash.yaml`
- 25-locale ARB scaffold (English populated, others copied verbatim —
  translate iteratively per plan §3.1)
- Material 3 theme, edge-to-edge system UI (no immersive modes)
- `go_router` skeleton, Riverpod providers
- Mandatory settings rows: Language, Support our work, Open source
  licenses (`showLicensePage()` wrapper)

**Phase 1 — Tier A readers**

- PDF (`pdfx`) with page indicator and resumed position
- Plain text / log / csv with BOM- and heuristic-driven charset decoding
- Markdown (`flutter_markdown` + GFM)
- Source code (50+ languages) via `flutter_highlight`
- Images including HEIC transcoding on Android
- HTML (`flutter_html`)
- EPUB (`epub_view`) with CFI position resume
- `receive_sharing_intent` wired so "Open with…" lands in the reader
- File picker entrypoint on the home screen

**Phase 2 — handoff + polish**

- Office formats (`.docx/.xlsx/.pptx/.odt/...`) route to a "Quick
  preview" page that opens the OS handler via `open_filex`
- Reading themes (light / sepia / dark / OLED black), font family
  (serif / sans / mono), font size — persisted via `shared_preferences`
- Bookmarks (drift table + dedicated screen)
- Reading position auto-saved per document, restored on next open
- Recents with auto-generated thumbnails (PDF first page, image
  compress) backed by drift
- Share via `share_plus`; print PDFs via `printing`

**Phase 3 — optional**

- CBZ comics (`archive` + `photo_view_gallery`)
- TTS for text/markdown/code/html/EPUB via `flutter_tts`
- OCR for images via `google_mlkit_text_recognition`
- Full-text search across all opened documents (FTS5 via drift)

What is intentionally **not** in scope:

- Native `android/`/`ios/` shells (run `flutter create . --platforms=…`)
- Splash slogan (blocked on product copy — `splashSlogan` is empty in
  every ARB)
- Translations beyond English (24 locales are verbatim copies; mark up
  translators on a per-locale basis)
- CBR/MOBI/AZW3/DJVU — proprietary, no usable Dart libs
- Cloud connectors (Drive/Dropbox/WebDAV) and cross-device sync —
  plan §7 open questions, need backend / OAuth keys
- Server-side LibreOffice conversion — plan §1 Tier B option (3)

## Bootstrap

```bash
flutter create . --platforms=android,ios   # one time, generates native shells
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

`build_runner` generates `lib/infrastructure/database/app_database.g.dart`
from the drift schema and the `app_localizations*.dart` files from the
ARB sources.

## Layout

See plan.md §4 for the full layered breakdown. In short:

```
lib/
  core/             theme · routing · lifecycle · errors
  domain/           pure-Dart models, reader prefs enum
  infrastructure/   handlers · mime · text decoding · database · tts
  application/      document opener · services · Riverpod providers
  presentation/
    readers/        one widget per Tier A format + office handoff + comic
    screens/        home · reader · bookmarks · search · settings
    widgets/        shared (ReaderOptionsSheet)
  l10n/             ARB files + supported_locales list
```
