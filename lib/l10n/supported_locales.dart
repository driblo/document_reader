import 'package:flutter/widgets.dart';

/// The 25 locales mandated by the project plan, listed in alphabetical
/// order of their English display name — that is the order the language
/// picker must render them in.
const List<Locale> kSupportedLocales = <Locale>[
  Locale('ar'), // Arabic
  Locale('bn'), // Bengali
  Locale('zh'), // Chinese (Simplified)
  Locale('cs'), // Czech
  Locale('en'), // English
  Locale('fr'), // French
  Locale('de'), // German
  Locale('hi'), // Hindi
  Locale('hu'), // Hungarian
  Locale('id'), // Indonesian
  Locale('it'), // Italian
  Locale('ja'), // Japanese
  Locale('ko'), // Korean
  Locale('mr'), // Marathi
  Locale('fa'), // Persian (Farsi)
  Locale('pl'), // Polish
  Locale('pt'), // Portuguese
  Locale('ru'), // Russian
  Locale('sk'), // Slovak
  Locale('es'), // Spanish
  Locale('ta'), // Tamil
  Locale('tr'), // Turkish
  Locale('uk'), // Ukrainian
  Locale('ur'), // Urdu
  Locale('vi'), // Vietnamese
];

/// English display names — used by the language picker so the labels
/// appear in the alphabetical order required by the spec regardless of
/// the user's currently active locale.
const Map<String, String> kLocaleDisplayNames = <String, String>{
  'ar': 'Arabic',
  'bn': 'Bengali',
  'zh': 'Chinese (Simplified)',
  'cs': 'Czech',
  'en': 'English',
  'fr': 'French',
  'de': 'German',
  'hi': 'Hindi',
  'hu': 'Hungarian',
  'id': 'Indonesian',
  'it': 'Italian',
  'ja': 'Japanese',
  'ko': 'Korean',
  'mr': 'Marathi',
  'fa': 'Persian',
  'pl': 'Polish',
  'pt': 'Portuguese',
  'ru': 'Russian',
  'sk': 'Slovak',
  'es': 'Spanish',
  'ta': 'Tamil',
  'tr': 'Turkish',
  'uk': 'Ukrainian',
  'ur': 'Urdu',
  'vi': 'Vietnamese',
};
