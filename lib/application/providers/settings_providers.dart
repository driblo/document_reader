import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Currently active app locale. `null` means "follow system".
final localeProvider = StateProvider<Locale?>((_) => null);

/// Currently active theme mode.
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);
