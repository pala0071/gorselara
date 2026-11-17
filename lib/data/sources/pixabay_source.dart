import 'package:dio/dio.dart';
import '../../core/utils.dart';
import '../../domain/image_item.dart';
import '../../domain/source_page.dart';
import 'base_source.dart';

class PixabaySource extends BaseSource {
  PixabaySource(super.api, super.credentials);
  @override
  SourceId get id => SourceId.pixabay;
  @override
  Future<SourcePage> search(String query, {String? cursor, CancelToken? cancelToken}) async {
    final page = int.tryParse(cursor ?? '') ?? 1;
    final j = await api.get('https://pixabay.com/api/', query: {
      'key': await credentials.requireKey(id), 'q': query, 'page': page,
      'per_page': 20, 'image_type': 'photo', 'safesearch': true,
    }, cancelToken: cancelToken);
    return SourcePage(items: asList(j['hits']).map((v) {
      final p = asMap(v); final original = str(p['imageURL']);
      return ImageItem(id: str(p['id']), source: id, title: str(p['tags']),
        thumbnailUrl: str(p['webformatURL']), imageUrl: original.isNotEmpty ? original : str(p['largeImageURL']),
        pageUrl: str(p['pageURL']), creator: str(p['user']),
        license: 'Pixabay Content License', licenseUrl: 'https://pixabay.com/service/license-summary/',
        width: integer(p['imageWidth']), height: integer(p['imageHeight']),
        originalAvailable: original.isNotEmpty,
        tags: str(p['tags']).split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList());
    }).toList(), nextCursor: page * 20 < (integer(j['totalHits']) ?? 0) ? '${page + 1}' : null);
  }
}
