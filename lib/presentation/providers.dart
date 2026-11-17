import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_strings.dart';
import '../data/local_store.dart';
import '../data/credential_store.dart';
import '../data/api_cache.dart';
import '../data/api_client.dart';
import '../data/search_repository.dart';
import '../data/download_service.dart';
import '../data/notification_service.dart';
import '../data/sources/openverse_source.dart';
import '../data/sources/wikimedia_source.dart';
import '../data/sources/pexels_source.dart';
import '../data/sources/pixabay_source.dart';
import '../data/sources/unsplash_source.dart';
import '../data/sources/google_source.dart';
import 'controllers/settings_controller.dart';
import 'controllers/search_controller.dart';
import 'controllers/library_controller.dart';
import 'controllers/download_controller.dart';

final storeProvider = Provider<LocalStore>((ref) => throw StateError('LocalStore must be initialized'));
final credentialProvider = Provider((ref) => CredentialStore());
final apiProvider = Provider((ref) {
  final api = ApiClient(ApiCache(ref.watch(storeProvider).cache));
  ref.onDispose(() => api.dio.close(force: true));
  return api;
});
final repositoryProvider = Provider((ref) {
  final api = ref.watch(apiProvider), keys = ref.watch(credentialProvider);
  final sources = [OpenverseSource(api, keys), WikimediaSource(api, keys), PexelsSource(api, keys),
    PixabaySource(api, keys), UnsplashSource(api, keys), GoogleSource(api, keys)];
  return SearchRepository({for (final source in sources) source.id: source});
});
final settingsProvider = StateNotifierProvider<SettingsController, SettingsState>((ref) => SettingsController(ref.watch(storeProvider)));
final stringsProvider = Provider((ref) => AppStrings(ref.watch(settingsProvider).language));
final searchProvider = StateNotifierProvider<ImageSearchController, SearchState>((ref) => ImageSearchController(ref.watch(repositoryProvider), ref.watch(storeProvider)));
final libraryProvider = StateNotifierProvider<LibraryController, int>((ref) => LibraryController(ref.watch(storeProvider)));
final notificationProvider = Provider<NotificationService>((ref) => throw StateError('Notifications must be initialized'));
final downloadServiceProvider = Provider((ref) => DownloadService(ref.watch(repositoryProvider), ref.watch(storeProvider)));
final downloadProvider = StateNotifierProvider<DownloadController, DownloadState>((ref) => DownloadController(ref.watch(downloadServiceProvider), ref.watch(notificationProvider)));
