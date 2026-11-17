import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/image_item.dart';
import '../domain/download_record.dart';
import '../core/app_exception.dart';
import '../core/utils.dart';
import 'search_repository.dart';
import 'local_store.dart';

class DownloadService {
  final SearchRepository repository;
  final LocalStore store;
  final Dio dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 25),
    receiveTimeout: const Duration(minutes: 3)));
  DownloadService(this.repository, this.store);
  Future<File> fetch(ImageItem image, void Function(double?) progress) async {
    final url = await repository.sources[image.source]!.downloadUrl(image);
    if (!webUrl(url)) throw const AppException(FailureKind.invalid);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/gorselara_${DateTime.now().microsecondsSinceEpoch}.part');
    final token = CancelToken();
    try {
      await dio.download(url, file.path, cancelToken: token, onReceiveProgress: (received, total) {
        if (received > 150 * 1024 * 1024) { token.cancel('File too large'); return; }
        progress(total > 0 ? received / total : null);
      });
      final handle = await file.open();
      final bytes = await handle.read(16); await handle.close();
      String? ext;
      if (bytes.length >= 3 && bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255) ext = 'jpg';
      if (bytes.length >= 8 && bytes[0] == 137 && bytes[1] == 80 && bytes[2] == 78 && bytes[3] == 71) ext = 'png';
      if (bytes.length >= 6 && String.fromCharCodes(bytes.take(6)).startsWith('GIF8')) ext = 'gif';
      if (bytes.length >= 12 && String.fromCharCodes(bytes.take(4)) == 'RIFF' &&
          String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
        ext = 'webp';
      }
      if (ext == null) throw const AppException(FailureKind.invalid);
      return await file.rename(file.path.replaceAll('.part', '.$ext'));
    } catch (e) {
      if (await file.exists()) await file.delete();
      if (e is DioException) throw AppException.from(e);
      rethrow;
    }
  }
  Future<void> save(ImageItem image, void Function(double?) progress) async {
    // On modern Android Gal inserts this app's new image through MediaStore.
    if (!await Gal.hasAccess(toAlbum: true)) await Gal.requestAccess(toAlbum: true);
    if (!await Gal.hasAccess(toAlbum: true)) throw const AppException(FailureKind.unauthorized);
    final file = await fetch(image, progress);
    try {
      await Gal.putImage(file.path, album: 'GörselAra');
      await store.addDownload(DownloadRecord(image: image, savedAt: DateTime.now(),
        fileName: file.uri.pathSegments.last));
    } finally { if (await file.exists()) await file.delete(); }
  }
}
