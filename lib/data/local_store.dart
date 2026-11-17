import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/image_item.dart';
import '../domain/download_record.dart';

class LocalStore {
  final Box<String> favorites, history, downloads, settings, cache;
  LocalStore(this.favorites, this.history, this.downloads, this.settings, this.cache);
  static Future<LocalStore> open() async {
    await Hive.initFlutter();
    final boxes = await Future.wait(['favorites', 'history', 'downloads', 'settings', 'cache']
        .map((name) => Hive.openBox<String>('gorselara_$name')));
    return LocalStore(boxes[0], boxes[1], boxes[2], boxes[3], boxes[4]);
  }
  List<ImageItem> get favoriteItems => favorites.values.map((s) => ImageItem.fromJson(
      Map<String, dynamic>.from(jsonDecode(s) as Map))).toList().reversed.toList();
  bool isFavorite(ImageItem image) => favorites.containsKey(image.key);
  Future<void> toggleFavorite(ImageItem image) async {
    if (isFavorite(image)) { await favorites.delete(image.key); }
    else { await favorites.put(image.key, jsonEncode(image.toJson())); }
  }
  List<String> get searches => history.values.toList().reversed.toList();
  Future<void> remember(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final key = q.toLowerCase();
    await history.delete(key);
    await history.put(key, q);
    while (history.length > 100) { await history.deleteAt(0); }
  }
  Future<void> addDownload(DownloadRecord record) async {
    await downloads.put(record.savedAt.microsecondsSinceEpoch.toString(), jsonEncode(record.toJson()));
  }
  List<DownloadRecord> get downloadItems => downloads.values.map((s) => DownloadRecord.fromJson(
      Map<String, dynamic>.from(jsonDecode(s) as Map))).toList().reversed.toList();
}
