import 'package:flutter/material.dart';

abstract class ThemeEvent {
  const ThemeEvent();
}

/// Event dispatched when the application starts to load the saved theme preference
class LoadThemeMode extends ThemeEvent {
  const LoadThemeMode();
}

/// Event dispatched when the user changes the theme mode (System, Light, Dark)
class ChangeThemeMode extends ThemeEvent {
  final ThemeMode themeMode;

  const ChangeThemeMode(this.themeMode);
}
