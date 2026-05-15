# Universal Document Reader — Flutter Development Plan

**Stack:** Flutter (stable channel) · Dart 3.x · Material 3 · Android + iOS
**Target SDKs:** Android 8.0 (API 26) and up · iOS 14 and up

---

## 1. Scope — what "all types of documents" actually means

Flutter has no single library that reads everything. The app needs a **handler registry** that maps MIME type / extension to a specific renderer. Realistic coverage tiers:

### Tier A — first-class, in-app rendering (MVP)
| Format | Package | Notes |
|---|---|---|
| PDF | `pdfx` or `syncfusion_flutter_pdfviewer` (free community license) | Page nav, search, zoom |
| Plain text, log, csv | built-in | Encoding detection (`charset`) |
| Markdown | `flutter_markdown` | + GFM tables/code blocks |
| Source code (50+ langs) | `flutter_highlight` + `highlight` | Theme switch |
| Images (jpg/png/webp/gif/bmp/heic) | `Image` + `photo_view` | HEIC on iOS native, decoded via `flutter_image_compress` on Android |
| HTML | `flutter_html` | Sandboxed, no JS |
| EPUB | `epub_view` | Reflowable, bookmarks |

### Tier B — convert-then-render (Phase 2)
DOCX / ODT / RTF / XLSX / PPTX / ODS / ODP — no good native Flutter renderers.

Two options:
1. **Local conversion**: `docx_to_text` + `excel` + `pptx` packages → extract text/tables, render in custom view. Loses formatting.
2. **Native viewer handoff**: open via Android `Intent.ACTION_VIEW` / iOS `UIDocumentInteractionController` (QuickLook). Better fidelity, but leaves the app.
3. **Server-side conversion to PDF** (LibreOffice headless on your bh1.sk server) — best fidelity, requires network and infra.

Recommendation: ship **(2) handoff** for MVP, add **(1) text extraction** later for search/preview, consider **(3)** only if users complain.

### Tier C — niche (Phase 3 / optional)
CBZ/CBR (comics — `archive` package + image viewer), MOBI/AZW3 (proprietary, complex), DJVU (no Dart lib), MIDI / sheet music, 3D (OBJ/STL via `model_viewer_plus`).

---

## 2. Architecture — Layered + Strategy

Not a game, so no ECS / game loop. Use a clean layered approach you already know from `email_client`:

```
┌─────────────────────────────────────────────────┐
│  Presentation  (Widgets, screens, Riverpod)     │
├─────────────────────────────────────────────────┤
│  Application   (DocumentOpener, ReaderRouter,   │
│                 RecentFilesService, Search)     │
├─────────────────────────────────────────────────┤
│  Domain        (Document, Bookmark, Annotation, │
│                 ReaderState — pure Dart)        │
├─────────────────────────────────────────────────┤
│  Infrastructure (FileSystem, MimeDetector,      │
│                  Handlers, SQLite, Prefs)       │
└─────────────────────────────────────────────────┘
```

**Key abstraction — `DocumentHandler` interface:**
```dart
abstract class DocumentHandler {
  bool canHandle(DocumentRef ref);          // by extension + magic bytes
  Future<ReaderScreen> buildReader(DocumentRef ref);
  Future<Thumbnail> generateThumbnail(DocumentRef ref);
  Future<String?> extractText(DocumentRef ref); // for indexing
}
```
Each format = one implementation. Registered in a `HandlerRegistry`. Adding a new format = new class, no touching existing code (open/closed).

**State management:** Riverpod 2.x — providers for current reader, recent files, settings, search index. Avoids Provider boilerplate, plays well with code generation.

**Persistence:** SQLite (`drift` package) for recent files, bookmarks, reading positions, full-text search index. `shared_preferences` only for app-level settings (language, theme).

---

## 3. Mandatory features — wired in from day one

Per `mobile-app-mandatory-features` skill — these are non-negotiable:

### 3.1 Localization — 25 locales
ARB files via Flutter's official `intl` + `flutter_localizations`. Generate with `flutter gen-l10n`. One `lib/l10n/app_<locale>.arb` per locale; English is template. Start by copying English to all 25; translate iteratively.

Locales required (alphabetical, as they must appear in the picker):
Arabic, Bengali, Chinese (Simplified), Czech, English, French, German, Hindi, Hungarian, Indonesian, Italian, Japanese, Korean, Marathi, Persian (Farsi), Polish, Portuguese, Russian, Slovak, Spanish, Tamil, Turkish, Ukrainian, Urdu, Vietnamese.

RTL handling: Arabic, Persian, Urdu — Flutter handles via `MaterialApp.locale` + `Directionality`. Test reader views with RTL early; PDF/EPUB libs are mostly LTR-assuming.

### 3.2 Translation accessor from the start
Every visible string goes through `AppLocalizations.of(context).xxx`. No inline strings, ever. Lint rule: `flutter_lints` + custom rule via `dart_code_metrics` to flag string literals in widget code.

### 3.3 No fullscreen
**Do not** call `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive*)` anywhere. Use `edgeToEdge` mode with translucent system bars instead — content can flow under, bars stay visible/tappable. Even in distraction-free "reading mode," at most dim the bottom bar — never hide it.

### 3.4 Settings → "Support our work"
Settings screen contains a row labeled with the localized `settings.supportLink` key. Tapping opens a new in-app screen (not a browser) titled with localized `support.headline` = "Support our work to keep this app without ads", followed by your support mechanism (donation link / Patreon / IAP — TBD). Pre-translated strings come from the skill's `references/support-strings.md` — copy directly into ARB files.

### 3.5 Splash screen with slogan
Use `flutter_native_splash` for real native splash (Android 12 SplashScreen API + iOS LaunchScreen.storyboard). The slogan goes through localization (`splash.slogan` key) and must be translated for all 25 locales.

**Blocker: I need the slogan from you before generating splash code.**

### 3.6 Open-source licenses page
Use Flutter's built-in `showLicensePage()` — it auto-aggregates from `pubspec.lock`, no manual list. Wire a Settings row labeled `settings.openSourceLicenses` to it. Sub-page title localized; license texts stay in original English.

---

## 4. Folder structure

```
lib/
├── main.dart
├── app.dart                       # MaterialApp, theming, locale, routing
├── l10n/
│   ├── app_en.arb                 # template
│   └── app_<locale>.arb           # × 25
├── core/
│   ├── theme/                     # Material 3 ColorSchemes, typography
│   ├── routing/                   # go_router config
│   ├── lifecycle/                 # AppLifecycleObserver — save state on pause
│   └── errors/                    # AppException, error reporter
├── domain/
│   ├── document.dart
│   ├── bookmark.dart
│   ├── annotation.dart
│   └── reader_state.dart
├── infrastructure/
│   ├── filesystem/                # SAF on Android, UIDocumentPicker on iOS
│   ├── mime/                      # extension + magic-byte detection
│   ├── database/                  # drift schema, migrations
│   ├── prefs/
│   └── handlers/
│       ├── handler_registry.dart
│       ├── pdf_handler.dart
│       ├── text_handler.dart
│       ├── markdown_handler.dart
│       ├── image_handler.dart
│       ├── html_handler.dart
│       ├── epub_handler.dart
│       ├── code_handler.dart
│       └── office_handoff_handler.dart
├── application/
│   ├── document_opener.dart       # entrypoint: ref → handler → screen
│   ├── recent_files_service.dart
│   ├── search_service.dart        # FTS5 across extracted text
│   └── providers/                 # Riverpod providers
└── presentation/
    ├── screens/
    │   ├── home/                  # recent + browse
    │   ├── browse/                # file picker, folder browser
    │   ├── reader/                # generic reader scaffold
    │   ├── search/
    │   └── settings/
    │       ├── settings_screen.dart
    │       ├── language_screen.dart
    │       ├── support_screen.dart
    │       └── licenses_screen.dart  # showLicensePage wrapper
    └── widgets/
```

---

## 5. Development phases

### Phase 0 — Scaffolding (1–2 days)
- `flutter create` with org id, Android/iOS bundle ids
- Add `intl`, `flutter_localizations`, generate l10n config
- Create all 25 ARB files (English populated, others copied)
- `flutter_native_splash` config (waiting on slogan)
- Material 3 theme, light/dark
- `go_router` skeleton
- Settings screen with the 3 mandatory rows (Language, Support our work, Open source licenses) — even before any reader works
- `drift` schema for `documents`, `recent`, `bookmarks`, `search_index`
- Lifecycle observer that saves reading position on pause
- CI: `flutter analyze`, `dart format --set-exit-if-changed`, unit test runner

**Exit criteria:** app launches, splash shows, all settings screens reachable, locale switcher works (even if 24 locales = English text).

### Phase 1 — MVP readers (1–2 weeks)
Implement Tier A handlers in this order: text → markdown → image → PDF → code → HTML → EPUB. Each ships with: handler class, reader screen, thumbnail, text extraction for search.

File entrypoints:
- **Android**: `file_picker` for in-app browse; `receive_sharing_intent` for "Open with…"; Storage Access Framework for folder-scoped access.
- **iOS**: same packages; document picker via UIDocumentPicker; "Open in" via share extension.

**Exit criteria:** all Tier A formats open, scroll smoothly, position persists across app kills, search across recents works.

### Phase 2 — Office handoff + polish (1 week)
- Office files (`.docx/.xlsx/.pptx/.odt/...`) open via native viewer handoff
- Bookmarks UI, annotations (start with PDF only)
- Reading themes (sepia, dark, OLED-black) for text/EPUB/Markdown
- Font size + family controls
- Share / print
- Recents with thumbnails
- All 25 locales translated (use a service or AI — verify Slovak personally)

**Exit criteria:** store-ready beta.

### Phase 3 — Optional (post-launch, prioritize by user feedback)
- Comics (CBZ/CBR)
- Local office-to-PDF conversion (or your server-side LibreOffice route)
- Cloud connectors (Drive, Dropbox, WebDAV)
- TTS for text/EPUB/PDF
- OCR for image-PDFs (`google_ml_kit_text_recognition`)
- Full-text search across all indexed docs
- Cross-device sync (your own backend — fits your Plesk/PostgreSQL setup)

---

## 6. Risks & tradeoffs to watch

1. **iOS file sandbox.** iOS doesn't let apps roam the filesystem. You only get what the user explicitly picks. UX must lean on "Open with…" and bookmarked folders, not a Files-app-style browser.
2. **Android scoped storage.** API 30+ enforces this. SAF only — no `MANAGE_EXTERNAL_STORAGE` unless absolutely needed (Play Store will challenge it).
3. **PDF library licensing.** Syncfusion's community license requires < $1M revenue and individual registration. `pdfx` is MPL-2.0, safer for unrestricted distribution.
4. **App size.** Bundling readers for every format inflates the binary. Use Flutter's deferred loading (`loadLibrary()`) for less-common handlers like EPUB or HTML.
5. **Office fidelity.** Anything short of server-side LibreOffice will produce visibly degraded DOCX/PPTX. Set expectations in UI ("Quick preview — open in [App] for full formatting").
6. **HEIC on Android.** Native decoder is patchy below API 30. Use `flutter_image_compress` to transcode.
7. **Heavy PDFs.** 500MB+ PDFs will OOM on budget devices. Cap page render resolution; release pages outside viewport.
8. **Encoding detection.** Plain text "all types" includes CP-1250 (Slovak Windows), UTF-8 with/without BOM, UTF-16. Use `charset` + heuristics. Manual override in reader UI.

---

## 7. Open questions for you

1. **App slogan** — required for splash screen, must be translatable.
2. **App name / brand** — for bundle ids and store listing.
3. **Monetization** — free + donate? IAP to unlock formats? Determines what goes under the "Support our work" message.
4. **Office handling preference** — handoff to native (fast, leaves app) vs server-side PDF conversion (uses your infra, stays in app)?
5. **Priority formats** — if I had to ship in 2 weeks with 5 formats, which 5? My guess: PDF, plain text, EPUB, image, Markdown.

---

## Mandatory features check

- [x] Localization scaffolded (25 locales, ARB files, alphabetical picker) — Phase 0
- [x] Strings go through translation layer (`AppLocalizations`, lint enforced) — Phase 0
- [x] System bottom bar stays visible (edge-to-edge, no `immersive*` modes) — global rule
- [x] Settings → "Support our work" link wired up — Phase 0
- [x] Splash screen shows slogan — Phase 0
- [x] Settings → "Open source licenses" sub-page (`showLicensePage()`) — Phase 0
