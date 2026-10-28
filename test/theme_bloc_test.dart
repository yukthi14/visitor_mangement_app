import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitor_mangement_app/core/constants/app_constants.dart';
import 'package:visitor_mangement_app/logic/blocs/theme/theme_bloc.dart';
import 'package:visitor_mangement_app/logic/blocs/theme/theme_event.dart';
import 'package:visitor_mangement_app/logic/blocs/theme/theme_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('ThemeBloc Tests', () {
    test('initial state defaults to ThemeMode.system', () {
      final bloc = ThemeBloc(sharedPreferences: prefs);
      expect(bloc.state.themeMode, ThemeMode.system);
    });

    test('LoadThemeMode defaults to ThemeMode.system when no preference is saved', () async {
      final bloc = ThemeBloc(sharedPreferences: prefs);
      bloc.add(const LoadThemeMode());

      await expectLater(
        bloc.stream,
        emits(const ThemeState(themeMode: ThemeMode.system)),
      );
    });

    test('LoadThemeMode restores dark theme mode when saved in prefs', () async {
      await prefs.setString(AppConstants.prefThemeMode, AppConstants.themeModeDark);
      final bloc = ThemeBloc(sharedPreferences: prefs);
      bloc.add(const LoadThemeMode());

      await expectLater(
        bloc.stream,
        emits(const ThemeState(themeMode: ThemeMode.dark)),
      );
    });

    test('LoadThemeMode restores light theme mode when saved in prefs', () async {
      await prefs.setString(AppConstants.prefThemeMode, AppConstants.themeModeLight);
      final bloc = ThemeBloc(sharedPreferences: prefs);
      bloc.add(const LoadThemeMode());

      await expectLater(
        bloc.stream,
        emits(const ThemeState(themeMode: ThemeMode.light)),
      );
    });

    test('ChangeThemeMode updates state and persists mode to SharedPreferences', () async {
      final bloc = ThemeBloc(sharedPreferences: prefs);

      bloc.add(const ChangeThemeMode(ThemeMode.dark));
      await expectLater(
        bloc.stream,
        emits(const ThemeState(themeMode: ThemeMode.dark)),
      );
      expect(prefs.getString(AppConstants.prefThemeMode), AppConstants.themeModeDark);

      bloc.add(const ChangeThemeMode(ThemeMode.light));
      await expectLater(
        bloc.stream,
        emits(const ThemeState(themeMode: ThemeMode.light)),
      );
      expect(prefs.getString(AppConstants.prefThemeMode), AppConstants.themeModeLight);

      bloc.add(const ChangeThemeMode(ThemeMode.system));
      await expectLater(
        bloc.stream,
        emits(const ThemeState(themeMode: ThemeMode.system)),
      );
      expect(prefs.getString(AppConstants.prefThemeMode), AppConstants.themeModeSystem);
    });
  });
}
