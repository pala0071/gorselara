import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_exception.dart';
import '../../data/search_repository.dart';
import '../../data/local_store.dart';
import '../../domain/image_item.dart';
import '../../domain/search_filter.dart';

class SearchState {
  final String query;
  final List<ImageItem> items;
  final Set<SourceId> selected;
  final SearchFilter filter;
  final bool loading, hasMore;
  final Map<SourceId, AppException> failures;
  final int unknownDates;
  final ImageItem? similar;
  const SearchState({this.query = '', this.items = const [],
    this.selected = const {SourceId.openverse, SourceId.wikimedia},
    this.filter = const SearchFilter(), this.loading = false, this.hasMore = false,
    this.failures = const {}, this.unknownDates = 0, this.similar});
  SearchState copy({List<ImageItem>? items, bool? loading, bool? hasMore,
    Map<SourceId, AppException>? failures, int? unknownDates}) => SearchState(
    query: query, items: items ?? this.items, selected: selected, filter: filter,
    loading: loading ?? this.loading, hasMore: hasMore ?? this.hasMore,
    failures: failures ?? this.failures, unknownDates: unknownDates ?? this.unknownDates, similar: similar);
}
class ImageSearchController extends StateNotifier<SearchState> {
  final SearchRepository repository;
  final LocalStore store;
  CancelToken _token = CancelToken();
  Map<SourceId, String?> _cursors = {};
  Set<SourceId> _started = {};
  ImageSearchController(this.repository, this.store) : super(const SearchState());
  Future<void> search(String query, {Set<SourceId>? selected, SearchFilter? filter, ImageItem? similar}) async {
    _token.cancel(); _token = CancelToken();
    _cursors = {}; _started = {};
    state = SearchState(query: query.trim(), selected: Set.unmodifiable(selected ?? state.selected),
      filter: filter ?? state.filter, similar: similar, hasMore: true);
    if (state.query.isEmpty || state.selected.isEmpty) { state = state.copy(hasMore: false); return; }
    // Start fetching before awaiting history persistence to avoid stale requests.
    final fetch = loadMore();
    await store.remember(state.query);
    await fetch;
  }
  Future<void> refresh() => search(state.query, similar: state.similar);
  Future<void> choose(Set<SourceId> ids) => search(state.query, selected: ids, similar: state.similar);
  Future<void> setFilter(SearchFilter filter) => search(state.query, filter: filter, similar: state.similar);
  Future<void> loadMore() async {
    if (state.loading || !state.hasMore) return;
    final token = _token;
    state = state.copy(loading: true, failures: {});
    // A filtered page may be empty while later source pages still contain matches.
    // Limit one UI request to three source pages to protect API quotas.
    for (var pass = 0; pass < 3; pass++) {
      final batch = await repository.fetch(query: state.query, selected: state.selected,
        filter: state.filter, cursors: Map.of(_cursors), started: Set.of(_started), token: token, similar: state.similar);
      if (token.isCancelled || !mounted) return;
      _cursors.addAll(batch.cursors); _started.addAll(batch.cursors.keys);
      final keys = state.items.map((i) => i.key).toSet();
      final urls = state.items.map((i) => i.imageUrl).toSet();
      final fresh = batch.items.where((i) => keys.add(i.key) && urls.add(i.imageUrl)).toList();
      final more = state.selected.any((id) => !_started.contains(id) || _cursors[id] != null);
      state = state.copy(items: [...state.items, ...fresh], failures: batch.failures,
        unknownDates: state.unknownDates + batch.unknownDates, hasMore: more);
      if (fresh.isNotEmpty || !more || batch.failures.isNotEmpty) break;
    }
    if (mounted && !token.isCancelled) state = state.copy(loading: false);
  }
  @override
  void dispose() { _token.cancel(); super.dispose(); }
}
