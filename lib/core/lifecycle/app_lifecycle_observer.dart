import 'package:flutter/widgets.dart';

/// Hooks app lifecycle events so the active reader can persist its
/// scroll/page position when the OS is about to background or kill the
/// process. Wire it from the reader screen's [State.initState] /
/// [State.dispose] with concrete callbacks.
class AppLifecycleObserver with WidgetsBindingObserver {
  AppLifecycleObserver({this.onPause, this.onResume});

  final Future<void> Function()? onPause;
  final Future<void> Function()? onResume;

  void attach() => WidgetsBinding.instance.addObserver(this);
  void detach() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        onPause?.call();
      case AppLifecycleState.resumed:
        onResume?.call();
      case AppLifecycleState.detached:
        onPause?.call();
    }
  }
}
