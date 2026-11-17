import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local_store.dart';
import '../../domain/image_item.dart';

class LibraryController extends StateNotifier<int> {
  final LocalStore store;
  LibraryController(this.store) : super(0);
  Future<void> toggle(ImageItem image) async { await store.toggleFavorite(image); state++; }
  Future<void> clearSearches() async { await store.history.clear(); state++; }
  Future<void> clearDownloads() async { await store.downloads.clear(); state++; }
  void refresh() { state++; }
}
