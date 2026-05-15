import 'package:flutter/material.dart';

enum ReaderTheme { light, sepia, dark, oledBlack }

enum ReaderFontFamily { serif, sans, mono }

class ReaderPreferences {
  const ReaderPreferences({
    this.theme = ReaderTheme.light,
    this.fontFamily = ReaderFontFamily.serif,
    this.fontSize = 16,
    this.encoding,
  });

  final ReaderTheme theme;
  final ReaderFontFamily fontFamily;
  final double fontSize;
  final String? encoding;

  ReaderPreferences copyWith({
    ReaderTheme? theme,
    ReaderFontFamily? fontFamily,
    double? fontSize,
    String? encoding,
  }) {
    return ReaderPreferences(
      theme: theme ?? this.theme,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      encoding: encoding ?? this.encoding,
    );
  }

  Color get backgroundColor => switch (theme) {
        ReaderTheme.light => const Color(0xFFFFFFFF),
        ReaderTheme.sepia => const Color(0xFFF4ECD8),
        ReaderTheme.dark => const Color(0xFF1E1E1E),
        ReaderTheme.oledBlack => const Color(0xFF000000),
      };

  Color get foregroundColor => switch (theme) {
        ReaderTheme.light => const Color(0xFF1A1A1A),
        ReaderTheme.sepia => const Color(0xFF3B3024),
        ReaderTheme.dark => const Color(0xFFE0E0E0),
        ReaderTheme.oledBlack => const Color(0xFFD0D0D0),
      };

  String? get fontFamilyName => switch (fontFamily) {
        ReaderFontFamily.serif => 'serif',
        ReaderFontFamily.sans => null,
        ReaderFontFamily.mono => 'monospace',
      };
}
