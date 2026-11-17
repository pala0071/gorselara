import 'package:dio/dio.dart';
import '../../core/utils.dart';
import '../../domain/image_item.dart';
import '../../domain/source_page.dart';
import 'base_source.dart';

class PexelsSource extends BaseSource {
  PexelsSource(super.api, super.credentials);
  @override
  SourceId get id => SourceId.pexels;
  @override
  Future<SourcePage> search(String query, {String? cursor, CancelToken? cancelToken}) async {
    final page = int.tryParse(cursor ?? '') ?? 1;
    final j = await api.get('https://api.pexels.com/v1/search',
      headers: {'Authorization': await credentials.requireKey(id)},
      query: {'query': query, 'page': page, 'per_page': 20}, cancelToken: cancelToken);
    return SourcePage(items: asList(j['photos']).map((v) {
      final p = asMap(v); final src = asMap(p['src']);
      return ImageItem(id: str(p['id']), source: id, title: plain(p['alt']),
        thumbnailUrl: str(src['medium']), imageUrl: str(src['original']),
        pageUrl: str(p['url']), creator: str(p['photographer']), creatorUrl: str(p['photographer_url']),
        license: 'Pexels License', licenseUrl: 'https://www.pexels.com/license/',
        width: integer(p['width']), height: integer(p['height']), originalAvailable: true);
    }).toList(), nextCursor: j['next_page'] != null ? '${page + 1}' : null);
  }
}
