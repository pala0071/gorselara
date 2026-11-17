import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_store.dart';

class SettingsState {
  final ThemeMode theme;
  final String language;
  const SettingsState({this.theme = ThemeMode.system, this.language = 'tr'});
}
class SettingsController extends StateNotifier<SettingsState> {
  final LocalStore store;
  SettingsController(this.store) : super(SettingsState(
    theme: ThemeMode.values.firstWhere((v) => v.name == store.settings.get('theme'), orElse: () => ThemeMode.system),
    language: store.settings.get('language', defaultValue: 'tr')!));
  Future<void> update({ThemeMode? theme, String? language}) async {
    final next = SettingsState(theme: theme ?? state.theme, language: language ?? state.language);
    await store.settings.putAll({'theme': next.theme.name, 'language': next.language});
    state = next;
  }
}
