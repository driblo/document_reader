import 'package:flutter_tts/flutter_tts.dart';

/// Thin wrapper around [FlutterTts] so the reader UI can call
/// `speak`/`stop` without dragging the platform plugin into widget code.
/// One instance per app session is enough; provided via Riverpod.
class TextToSpeech {
  TextToSpeech() : _tts = FlutterTts();

  final FlutterTts _tts;
  bool _speaking = false;

  bool get isSpeaking => _speaking;

  Future<void> configureForLocale(String? localeTag) async {
    if (localeTag == null) return;
    final available = await _tts.isLanguageAvailable(localeTag);
    if (available == true) {
      await _tts.setLanguage(localeTag);
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    _speaking = true;
    _tts.setCompletionHandler(() => _speaking = false);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _speaking = false;
  }

  Future<void> dispose() => _tts.stop();
}
