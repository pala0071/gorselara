import 'package:dio/dio.dart';
import 'image_item.dart';
import 'source_page.dart';

abstract interface class ImageSource {
  SourceId get id;
  Future<SourcePage> search(String query, {String? cursor, CancelToken? cancelToken});
  Future<SourcePage> similar(ImageItem image, {String? cursor, CancelToken? cancelToken});
  Future<String> downloadUrl(ImageItem image);
}
