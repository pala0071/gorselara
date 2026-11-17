import 'package:dio/dio.dart';
import '../../domain/image_item.dart';
import '../../domain/image_source.dart';
import '../../domain/source_page.dart';
import '../api_client.dart';
import '../credential_store.dart';

abstract class BaseSource implements ImageSource {
  final ApiClient api;
  final CredentialStore credentials;
  BaseSource(this.api, this.credentials);
  @override
  Future<SourcePage> similar(ImageItem image, {String? cursor, CancelToken? cancelToken}) {
    final query = image.tags.isNotEmpty ? image.tags.take(4).join(' ') : image.title;
    return search(query, cursor: cursor, cancelToken: cancelToken);
  }
  @override
  Future<String> downloadUrl(ImageItem image) async => image.imageUrl;
}
