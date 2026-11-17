import 'package:dio/dio.dart';
import '../../core/utils.dart';
import '../../domain/image_item.dart';
import '../../domain/source_page.dart';
import '../../core/app_exception.dart';
import 'base_source.dart';

class UnsplashSource extends BaseSource {
  UnsplashSource(super.api, super.credentials);
  @override
  SourceId get id => SourceId.unsplash;
  Future<Map<String, dynamic>> get headers async => {
    'Authorization': 'Client-ID ${await credentials.requireKey(id)}', 'Accept-Version': 'v1',
  };
  @override
  Future<SourcePage> search(String query, {String? cursor, CancelToken? cancelToken}) async {
    final page = int.tryParse(cursor ?? '') ?? 1;
    final j = await api.get('https://api.unsplash.com/search/photos', headers: await headers,
      query: {'query': query, 'page': page, 'per_page': 20, 'content_filter': 'high'}, cancelToken: cancelToken);
    return SourcePage(items: asList(j['results']).map((v) {
      final p = asMap(v), urls = asMap(p['urls']), links = asMap(p['links']), user = asMap(p['user']);
      return ImageItem(id: str(p['id']), source: id, title: plain(p['description'] ?? p['alt_description']),
        thumbnailUrl: str(urls['small']), imageUrl: str(urls['full']),
        pageUrl: referral(str(links['html'])), creator: str(user['name']),
        creatorUrl: referral(str(asMap(user['links'])['html'])),
        license: 'Unsplash License', licenseUrl: 'https://unsplash.com/license',
        width: integer(p['width']), height: integer(p['height']),
        date: DateTime.tryParse(str(p['created_at'])), dateKind: ImageDateKind.published,
        downloadTrackingUrl: str(links['download_location']), originalAvailable: true,
        tags: asList(p['tags']).map((t) => str(asMap(t)['title'])).where((s) => s.isNotEmpty).toList());
    }).toList(), nextCursor: page < (integer(j['total_pages']) ?? 0) ? '${page + 1}' : null);
  }
  @override
  Future<String> downloadUrl(ImageItem image) async {
    final tracking = Uri.tryParse(image.downloadTrackingUrl ?? '');
    if (tracking == null || tracking.scheme != 'https' || tracking.host != 'api.unsplash.com') {
      throw const AppException(FailureKind.invalid);
    }
    final j = await api.get(tracking.toString(), headers: await headers, cached: false);
    final url = str(j['url']);
    if (!webUrl(url)) throw const AppException(FailureKind.invalid);
    return url;
  }
}
