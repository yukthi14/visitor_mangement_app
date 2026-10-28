import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences sharedPreferences;

  ThemeBloc({required this.sharedPreferences})
      : super(const ThemeState(themeMode: ThemeMode.system)) {
    on<LoadThemeMode>(_onLoadThemeMode);
    on<ChangeThemeMode>(_onChangeThemeMode);
  }

  void _onLoadThemeMode(LoadThemeMode event, Emitter<ThemeState> emit) {
    final savedMode = sharedPreferences.getString(AppConstants.prefThemeMode) ??
        AppConstants.themeModeSystem;
    emit(ThemeState(themeMode: parseThemeMode(savedMode)));
  }

  Future<void> _onChangeThemeMode(
      ChangeThemeMode event, Emitter<ThemeState> emit) async {
    await sharedPreferences.setString(
      AppConstants.prefThemeMode,
      modeToString(event.themeMode),
    );
    emit(ThemeState(themeMode: event.themeMode));
  }

  static ThemeMode parseThemeMode(String mode) {
    switch (mode) {
      case AppConstants.themeModeLight:
        return ThemeMode.light;
      case AppConstants.themeModeDark:
        return ThemeMode.dark;
      case AppConstants.themeModeSystem:
      default:
        return ThemeMode.system;
    }
  }

  static String modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppConstants.themeModeLight;
      case ThemeMode.dark:
        return AppConstants.themeModeDark;
      case ThemeMode.system:
        return AppConstants.themeModeSystem;
    }
  }
}
