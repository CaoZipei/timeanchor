import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 主题模式 Provider
class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.light; // 默认浅色
  }

  void _load() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_key);
    if (val == 'dark') state = ThemeMode.dark;
    else if (val == 'system') state = ThemeMode.system;
    else state = ThemeMode.light;
  }

  void setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
