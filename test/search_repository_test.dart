import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gorselara/core/app_exception.dart';
import 'package:gorselara/domain/image_item.dart';
import 'package:gorselara/domain/image_source.dart';
import 'package:gorselara/domain/search_filter.dart';
import 'package:gorselara/domain/source_page.dart';
import 'package:gorselara/data/search_repository.dart';

class FakeSource implements ImageSource {
  @override
  final SourceId id;
  final bool fail;
  int calls = 0;
  FakeSource(this.id, {this.fail = false});
  @override
  Future<SourcePage> search(String query, {String? cursor, CancelToken? cancelToken}) async {
    calls++;
    if (fail) throw const AppException(FailureKind.quota);
    return SourcePage(items: List.generate(2, (i) => ImageItem(id: '$i', source: id,
      title: '$i', thumbnailUrl: 'https://example.org/${id.name}/$i.jpg',
      imageUrl: 'https://example.org/${id.name}/$i.jpg', pageUrl: 'https://example.org')),
      nextCursor: cursor == null ? '2' : null);
  }
  @override
  Future<SourcePage> similar(ImageItem image, {String? cursor, CancelToken? cancelToken}) => search('', cursor: cursor, cancelToken: cancelToken);
  @override
  Future<String> downloadUrl(ImageItem image) async => image.imageUrl;
}
void main() {
  test('interleaves sources and preserves independent cursors', () async {
    final a = FakeSource(SourceId.openverse), b = FakeSource(SourceId.wikimedia);
    final repo = SearchRepository({a.id: a, b.id: b});
    final batch = await repo.fetch(query: 'cat', selected: {a.id, b.id}, filter: const SearchFilter(),
      cursors: {}, started: {}, token: CancelToken());
    expect(batch.items.map((i) => i.source).toList(), [a.id, b.id, a.id, b.id]);
    expect(batch.cursors, {a.id: '2', b.id: '2'});
    await repo.fetch(query: 'cat', selected: {a.id, b.id}, filter: const SearchFilter(),
      cursors: {a.id: null, b.id: '2'}, started: {a.id, b.id}, token: CancelToken());
    expect(a.calls, 1);
    expect(b.calls, 2);
  });
  test('one source failure does not discard other results', () async {
    final a = FakeSource(SourceId.openverse), b = FakeSource(SourceId.pexels, fail: true);
    final repo = SearchRepository({a.id: a, b.id: b});
    final batch = await repo.fetch(query: 'cat', selected: {a.id, b.id}, filter: const SearchFilter(),
      cursors: {}, started: {}, token: CancelToken());
    expect(batch.items.length, 2);
    expect(batch.failures[b.id]?.kind, FailureKind.quota);
    expect(batch.cursors.containsKey(b.id), isFalse);
  });
  test('unknown dates are counted and excluded without exhausting the source', () async {
    final source = FakeSource(SourceId.openverse);
    final batch = await SearchRepository({source.id: source}).fetch(query: 'cat', selected: {source.id},
      filter: SearchFilter(date: DateTime(2020)), cursors: {}, started: {}, token: CancelToken());
    expect(batch.items, isEmpty);
    expect(batch.unknownDates, 2);
    expect(batch.cursors[source.id], '2');
  });
}
