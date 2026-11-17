import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/utils.dart';
import '../../core/app_exception.dart';
import '../../domain/image_item.dart';
import '../../domain/source_page.dart';
import 'base_source.dart';

class WikimediaSource extends BaseSource {
  WikimediaSource(super.api, super.credentials);
  @override
  SourceId get id => SourceId.wikimedia;
  @override
  Future<SourcePage> search(String query, {String? cursor, CancelToken? cancelToken}) async {
    final j = await api.get('https://commons.wikimedia.org/w/api.php', query: {
      'action': 'query', 'format': 'json', 'formatversion': 2,
      'generator': 'search', 'gsrsearch': '$query filetype:bitmap', 'gsrnamespace': 6,
      'gsrlimit': 20, 'prop': 'imageinfo', 'iiprop': 'url|size|timestamp|extmetadata',
      'iiextmetadatafilter': 'Artist|LicenseShortName|LicenseUrl', 'iiurlwidth': 600,
      if (cursor != null) ...asMap(jsonDecode(cursor)),
    }, cancelToken: cancelToken);
    if (j['error'] != null) throw const AppException(FailureKind.server);
    final items = <ImageItem>[];
    for (final p in asList(asMap(j['query'])['pages'])) {
      final page = asMap(p);
      final infos = asList(page['imageinfo']);
      if (infos.isEmpty) continue;
      final info = asMap(infos.first);
      final meta = asMap(info['extmetadata']);
      final url = str(info['url']);
      if (!webUrl(url)) continue;
      items.add(ImageItem(id: str(page['pageid']), source: id,
        title: str(page['title']).replaceFirst('File:', ''),
        thumbnailUrl: str(info['thumburl']).isEmpty ? url : str(info['thumburl']),
        imageUrl: url, pageUrl: str(info['descriptionurl']),
        width: integer(info['width']), height: integer(info['height']),
        creator: plain(asMap(meta['Artist'])['value']),
        license: plain(asMap(meta['LicenseShortName'])['value']),
        licenseUrl: str(asMap(meta['LicenseUrl'])['value']),
        date: DateTime.tryParse(str(info['timestamp'])), dateKind: ImageDateKind.uploaded,
        originalAvailable: true));
    }
    return SourcePage(items: items, nextCursor: j['continue'] is Map ? jsonEncode(j['continue']) : null);
  }
}
