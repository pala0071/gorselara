import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/image_item.dart';
import '../../data/download_service.dart';
import '../../data/notification_service.dart';
import '../../core/app_exception.dart';
import '../../core/app_strings.dart';

class DownloadState {
  final bool busy;
  final double? progress;
  final String? itemKey;
  const DownloadState({this.busy = false, this.progress, this.itemKey});
}
class DownloadController extends StateNotifier<DownloadState> {
  final DownloadService service;
  final NotificationService notifications;
  DownloadController(this.service, this.notifications) : super(const DownloadState());
  Future<void> save(ImageItem image, AppStrings s) async {
    if (state.busy) return;
    state = DownloadState(busy: true, itemKey: image.key);
    final id = DateTime.now().millisecondsSinceEpoch % 1000000000;
    var lastNotice = DateTime.fromMillisecondsSinceEpoch(0);
    await notifications.request();
    try {
      await service.save(image, (value) {
        state = DownloadState(busy: true, progress: value, itemKey: image.key);
        if (DateTime.now().difference(lastNotice).inMilliseconds > 1000) {
          lastNotice = DateTime.now();
          notifications.show(id, s.t('Görsel indiriliyor', 'Downloading image'), image.title,
            ongoing: true, percent: value == null ? null : (value * 100).floor().clamp(0, 100).toInt());
        }
      });
      await notifications.show(id, s.t('Galeriye kaydedildi', 'Saved to gallery'), 'Pictures/GörselAra');
    } catch (e) {
      await notifications.show(id, s.t('İndirme başarısız', 'Download failed'), s.error(AppException.from(e)));
      rethrow;
    } finally { state = const DownloadState(); }
  }
}
