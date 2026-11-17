import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/image_item.dart';
import '../../domain/search_filter.dart';
import '../providers.dart';
import '../widgets/search_box.dart';
import '../widgets/source_chips.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/image_grid.dart';
import '../widgets/shimmer_grid.dart';
import '../widgets/status_panel.dart';
import 'settings_screen.dart';
import 'library_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends ConsumerState<HomeScreen> {
  final scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      final state = ref.read(searchProvider);
      if (scroll.position.extentAfter < 600 && !state.loading && state.hasMore && state.failures.isEmpty) {
        ref.read(searchProvider.notifier).loadMore();
      }
    });
  }
  @override
  void dispose() { scroll.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider), s = ref.watch(stringsProvider), download = ref.watch(downloadProvider);
    return Scaffold(appBar: AppBar(title: const Text('GörselAra'), actions: [
      IconButton(tooltip: s.t('Kütüphanem', 'My library'), icon: const Icon(Icons.collections_bookmark_outlined),
        onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const LibraryScreen()))),
      IconButton(tooltip: s.t('Ayarlar', 'Settings'), icon: const Icon(Icons.settings_outlined),
        onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SettingsScreen()))),
    ]), body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 4), child: Column(children: [
        const SearchBox(), const SizedBox(height: 10), const SourceChips(),
        Row(children: [TextButton.icon(onPressed: () => showModalBottomSheet<void>(context: context,
          isScrollControlled: true, showDragHandle: true, builder: (_) => const FilterSheet()),
          icon: const Icon(Icons.tune), label: Text(s.t('Filtreler', 'Filters'))), const Spacer(),
          const Text('Ultra HD'), Switch(value: state.filter.resolution == Resolution.uhd, onChanged: (v) =>
            ref.read(searchProvider.notifier).setFilter(SearchFilter(resolution: v ? Resolution.uhd : Resolution.all,
              date: state.filter.date, direction: state.filter.direction)))]),
        if (state.filter.date != null) Text(s.t('Tarih cihazda filtrelenir · Tarihi bilinmeyen: ${state.unknownDates}',
          'Dates filtered on-device · Unknown dates: ${state.unknownDates}'), style: Theme.of(context).textTheme.bodySmall),
        if (state.similar != null) Text(s.t(state.similar!.source == SourceId.openverse && state.selected.length == 1
          ? 'İlişkili görseller' : 'Etiketlere göre benzer sonuçlar', 'Related / tag-based results')),
      ])),
      if (download.busy) LinearProgressIndicator(value: download.progress),
      Expanded(child: RefreshIndicator(onRefresh: () => ref.read(searchProvider.notifier).refresh(),
        child: CustomScrollView(controller: scroll, physics: const AlwaysScrollableScrollPhysics(), slivers: [
          if (state.query.isEmpty) SliverToBoxAdapter(child: StatusPanel(icon: Icons.travel_explore,
            message: s.t('Bir kelime yaz, kaynakları seç ve keşfet.\nOpenverse ve Wikimedia anahtarsız çalışır.',
              'Type a word, select sources and explore.\nOpenverse and Wikimedia need no API key.'))),
          if (state.selected.isEmpty) SliverToBoxAdapter(child: StatusPanel(icon: Icons.filter_alt_off,
            message: s.t('En az bir kaynak seçin.', 'Select at least one source.'))),
          if (state.items.isNotEmpty) SliverPadding(padding: const EdgeInsets.all(16), sliver: ImageGrid(images: state.items, heroPrefix: 'search')),
          if (state.loading) const SliverToBoxAdapter(child: ShimmerGrid()),
          if (!state.loading && state.query.isNotEmpty && state.items.isEmpty && state.selected.isNotEmpty)
            SliverToBoxAdapter(child: StatusPanel(icon: Icons.image_search, message: s.t('Bu filtrelerle sonuç bulunamadı.', 'No results for these filters.'))),
          if (state.failures.isNotEmpty) SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16),
            child: Column(children: [for (final entry in state.failures.entries) ListTile(
              leading: const Icon(Icons.info_outline), title: Text(entry.key.label), subtitle: Text(s.error(entry.value))),
              FilledButton.tonal(onPressed: state.loading ? null : () => ref.read(searchProvider.notifier).loadMore(),
                child: Text(s.t('Yeniden dene', 'Retry')))]))),
          if (!state.loading && state.hasMore && state.failures.isEmpty) SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(16), child: OutlinedButton(onPressed: () => ref.read(searchProvider.notifier).loadMore(),
              child: Text(s.t('Daha fazla yükle', 'Load more'))))),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]))),
    ])));
  }
}
