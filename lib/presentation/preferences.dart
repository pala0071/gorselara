import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final settingsBox = Provider<Box<String>>((ref) => throw StateError('Settings not opened'));
final historyBox = Provider<Box<String>>((ref) => throw StateError('History not opened'));
final themeProvider = StateNotifierProvider<ThemeController, ThemeMode>(
  (ref) => ThemeController(ref.watch(settingsBox)));

class ThemeController extends StateNotifier<ThemeMode> {
  final Box<String> box;
  ThemeController(this.box) : super(ThemeMode.values.firstWhere(
    (v) => v.name == box.get('theme'), orElse: () => ThemeMode.system));
  Future<void> change(ThemeMode value) async {
    await box.put('theme', value.name);
    state = value;
  }
}
