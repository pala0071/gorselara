import 'app_exception.dart';

class AppStrings {
  final String language;
  const AppStrings(this.language);
  String t(String tr, String en) => language == 'tr' ? tr : en;
  String error(AppException e) => switch (e.kind) {
    FailureKind.network => t('İnternet bağlantısı kurulamadı. Bağlantınızı kontrol edin.', 'Could not connect. Check your internet connection.'),
    FailureKind.timeout => t('Kaynak zamanında yanıt vermedi. Yeniden deneyin.', 'The source timed out. Please retry.'),
    FailureKind.unauthorized => t('API anahtarı geçersiz veya erişim izni yok.', 'Invalid API key or access denied.'),
    FailureKind.quota => t('Kaynağın API limiti doldu. Daha sonra deneyin.', 'API rate limit reached. Try again later.'),
    FailureKind.server => t('Kaynak şu anda kullanılamıyor.', 'This source is currently unavailable.'),
    FailureKind.missingKey => t('Ayarlar bölümünden API anahtarını girin.', 'Add an API key in Settings.'),
    FailureKind.cancelled => t('İşlem iptal edildi.', 'Operation cancelled.'),
    FailureKind.invalid => t('Sonuç veya dosya işlenemedi. Yeniden deneyin.', 'Could not process the response or file. Please retry.'),
  };
}
