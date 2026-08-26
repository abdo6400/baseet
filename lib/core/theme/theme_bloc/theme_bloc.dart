import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeBloc(this._prefs) : super(ThemeState(mode: _getInitialMode(_prefs))) {
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  static ThemeMode _getInitialMode(SharedPreferences prefs) {
    final modeString = prefs.getString(_themeKey);
    if (modeString == 'dark') return ThemeMode.dark;
    if (modeString == 'light') return ThemeMode.light;
    return ThemeMode.light;
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(mode: event.mode));
    await _prefs.setString(_themeKey, event.mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
