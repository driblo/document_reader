import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/reader_preferences.dart';

const _keyTheme = 'reader.theme';
const _keyFont = 'reader.fontFamily';
const _keySize = 'reader.fontSize';
const _keyEncoding = 'reader.encoding';

/// Backing store. Set during app bootstrap via [overrideWithValue] so the
/// first frame already sees real preferences.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope',
  ),
);

class ReaderPreferencesController extends StateNotifier<ReaderPreferences> {
  ReaderPreferencesController(this._prefs)
      : super(ReaderPreferences(
          theme: ReaderTheme
              .values[_prefs.getInt(_keyTheme) ?? ReaderTheme.light.index],
          fontFamily: ReaderFontFamily.values[
              _prefs.getInt(_keyFont) ?? ReaderFontFamily.serif.index],
          fontSize: _prefs.getDouble(_keySize) ?? 16,
          encoding: _prefs.getString(_keyEncoding),
        ));

  final SharedPreferences _prefs;

  Future<void> setTheme(ReaderTheme theme) async {
    state = state.copyWith(theme: theme);
    await _prefs.setInt(_keyTheme, theme.index);
  }

  Future<void> setFont(ReaderFontFamily font) async {
    state = state.copyWith(fontFamily: font);
    await _prefs.setInt(_keyFont, font.index);
  }

  Future<void> setSize(double size) async {
    state = state.copyWith(fontSize: size);
    await _prefs.setDouble(_keySize, size);
  }

  Future<void> setEncoding(String? encoding) async {
    state = state.copyWith(encoding: encoding);
    if (encoding == null) {
      await _prefs.remove(_keyEncoding);
    } else {
      await _prefs.setString(_keyEncoding, encoding);
    }
  }
}

final readerPreferencesProvider =
    StateNotifierProvider<ReaderPreferencesController, ReaderPreferences>(
  (ref) => ReaderPreferencesController(ref.watch(sharedPreferencesProvider)),
);
