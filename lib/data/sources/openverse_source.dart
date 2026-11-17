import 'package:dio/dio.dart';
import '../../core/utils.dart';
import '../../domain/image_item.dart';
import '../../domain/source_page.dart';
import 'base_source.dart';

class OpenverseSource extends BaseSource {
  OpenverseSource(super.api, super.credentials);
  @override
  SourceId get id => SourceId.openverse;
  ImageItem parse(Map<String, dynamic> j) => ImageItem(
    id: str(j['id']), source: id, title: plain(j['title']),
    thumbnailUrl: str(j['thumbnail']), imageUrl: str(j['url']),
    pageUrl: str(j['foreign_landing_url']), creator: plain(j['creator']),
    creatorUrl: str(j['creator_url']), license: '${str(j['license']).toUpperCase()} ${str(j['license_version'])}'.trim(),
    licenseUrl: str(j['license_url']), width: integer(j['width']), height: integer(j['height']),
    date: DateTime.tryParse(str(j['indexed_on'])), dateKind: ImageDateKind.indexed,
    tags: asList(j['tags']).map((t) => str(asMap(t)['name'])).where((t) => t.isNotEmpty).toList(),
  );
  @override
  Future<SourcePage> search(String query, {String? cursor, CancelToken? cancelToken}) async {
    final page = int.tryParse(cursor ?? '') ?? 1;
    final j = await api.get('https://api.openverse.org/v1/images/',
      query: {'q': query, 'page': page, 'page_size': 20, 'mature': false}, cancelToken: cancelToken);
    return SourcePage(items: asList(j['results']).map((v) => parse(asMap(v))).toList(),
      nextCursor: j['next'] != null ? '${page + 1}' : null);
  }
  @override
  Future<SourcePage> similar(ImageItem image, {String? cursor, CancelToken? cancelToken}) async {
    if (image.source != id) return super.similar(image, cursor: cursor, cancelToken: cancelToken);
    final j = await api.get('https://api.openverse.org/v1/images/${Uri.encodeComponent(image.id)}/related/',
      cancelToken: cancelToken);
    return SourcePage(items: asList(j['results']).map((v) => parse(asMap(v))).toList());
  }
}
