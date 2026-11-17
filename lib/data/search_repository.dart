import 'package:dio/dio.dart';
import '../domain/image_item.dart';
import '../domain/image_source.dart';
import '../domain/search_filter.dart';
import '../core/app_exception.dart';
import '../core/utils.dart';

class SearchBatch {
  final List<ImageItem> items;
  final Map<SourceId, String?> cursors;
  final Map<SourceId, AppException> failures;
  final int unknownDates;
  const SearchBatch(this.items, this.cursors, this.failures, this.unknownDates);
}

class SearchRepository {
  final Map<SourceId, ImageSource> sources;
  SearchRepository(this.sources);
  Future<SearchBatch> fetch({required String query, required Set<SourceId> selected,
    required SearchFilter filter, required Map<SourceId, String?> cursors,
    required Set<SourceId> started, required CancelToken token, ImageItem? similar}) async {
    final next = <SourceId, String?>{};
    final errors = <SourceId, AppException>{};
    final buckets = <SourceId, List<ImageItem>>{};
    var unknownDates = 0;
    await Future.wait(selected.map((id) async {
      if (started.contains(id) && cursors[id] == null) return;
      try {
        final source = sources[id]!;
        final page = similar == null
          ? await source.search(query, cursor: cursors[id], cancelToken: token)
          : await source.similar(similar, cursor: cursors[id], cancelToken: token);
        next[id] = page.nextCursor;
        if (filter.date != null) unknownDates += page.items.where((i) => i.date == null).length;
        buckets[id] = page.items.where((i) => webUrl(i.imageUrl) && webUrl(i.thumbnailUrl)
          && filter.matches(i)).toList();
      } catch (e) { errors[id] = AppException.from(e); }
    }));
    final mixed = <ImageItem>[];
    for (var i = 0; ; i++) {
      var added = false;
      for (final id in selected) {
        final bucket = buckets[id] ?? [];
        if (i < bucket.length) { mixed.add(bucket[i]); added = true; }
      }
      if (!added) break;
    }
    return SearchBatch(mixed, next, errors, unknownDates);
  }
}
