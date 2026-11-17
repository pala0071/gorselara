import 'package:dio/dio.dart';
import '../../core/utils.dart';
import '../../core/app_exception.dart';
import '../../domain/image_item.dart';
import '../../domain/source_page.dart';
import 'base_source.dart';

class GoogleSource extends BaseSource {
  GoogleSource(super.api, super.credentials);
  @override
  SourceId get id => SourceId.google;
  @override
  Future<SourcePage> search(String query, {String? cursor, CancelToken? cancelToken}) async {
    final cx = await credentials.read('google_cx');
    if (cx.isEmpty) throw const AppException(FailureKind.missingKey);
    final start = int.tryParse(cursor ?? '') ?? 1;
    final j = await api.get('https://customsearch.googleapis.com/customsearch/v1', query: {
      'key': await credentials.requireKey(id), 'cx': cx, 'q': query,
      'searchType': 'image', 'safe': 'active', 'num': 10, 'start': start,
    }, cancelToken: cancelToken);
    final next = asList(asMap(j['queries'])['nextPage']);
    final nextIndex = next.isEmpty ? null : integer(asMap(next.first)['startIndex']);
    return SourcePage(items: asList(j['items']).map((v) {
      final p = asMap(v), image = asMap(p['image']);
      return ImageItem(id: str(p['link']), source: id, title: plain(p['title']),
        thumbnailUrl: str(image['thumbnailLink']), imageUrl: str(p['link']),
        pageUrl: str(image['contextLink']), width: integer(image['width']), height: integer(image['height']),
        license: 'Check source license');
    }).toList(), nextCursor: nextIndex != null && nextIndex <= 91 ? '$nextIndex' : null);
  }
}
