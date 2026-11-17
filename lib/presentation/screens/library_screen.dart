import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers.dart';
import '../widgets/image_grid.dart';
import 'viewer_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(libraryProvider);
    final s = ref.watch(stringsProvider), store = ref.read(storeProvider);
    final favorites = store.favoriteItems, downloads = store.downloadItems;
    return DefaultTabController(length: 3, child: Scaffold(appBar: AppBar(title: Text(s.t('Kütüphanem', 'My library')),
      bottom: TabBar(tabs: [Tab(text: s.t('Favoriler', 'Favorites')), Tab(text: s.t('Aramalar', 'Searches')), Tab(text: s.t('İndirilenler', 'Downloads'))])),
      body: TabBarView(children: [
        favorites.isEmpty ? Center(child: Text(s.t('Henüz favori yok.', 'No favorites yet.'))) : CustomScrollView(slivers: [
          SliverPadding(padding: const EdgeInsets.all(16), sliver: ImageGrid(images: favorites, heroPrefix: 'favorites'))]),
        ListView(children: [ListTile(title: Text(s.t('Arama geçmişini temizle', 'Clear search history')),
          trailing: const Icon(Icons.delete_outline), onTap: () => ref.read(libraryProvider.notifier).clearSearches()),
          for (final query in store.searches) ListTile(leading: const Icon(Icons.history), title: Text(query),
            onTap: () { ref.read(searchProvider.notifier).search(query); Navigator.pop(context); })]),
        ListView(children: [ListTile(title: Text(s.t('İndirme geçmişini temizle', 'Clear download history')),
          subtitle: Text(s.t('Galerideki dosyalar silinmez.', 'Gallery files are kept.')), trailing: const Icon(Icons.delete_outline),
          onTap: () => ref.read(libraryProvider.notifier).clearDownloads()),
          for (var i = 0; i < downloads.length; i++) ListTile(leading: const Icon(Icons.download_done),
            title: Text(downloads[i].image.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${DateFormat('dd.MM.yyyy HH:mm').format(downloads[i].savedAt)}\n${downloads[i].fileName}'),
            onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => ViewerScreen(
              images: downloads.map((r) => r.image).toList(), initialIndex: i, heroPrefix: 'downloads'))))]),
      ])));
  }
}
