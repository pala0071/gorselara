# GörselAra 2.0 — Blogspot

Yalnızca Blogspot sitelerindeki indekslenmiş görselleri arar. API anahtarı istemez. Google görsel araması `site:blogspot.com` ve alan kısıtıyla **uygulama içindeki Android WebView** üzerinde gösterilir. Chrome, Pinterest veya başka uygulama açılmaz. Bu sürüm özel bir yerel görsel ızgarası değildir.

Arama kutusuna kelime yazın. Görselleri sayfada açın; üstte geri/ileri, yenile ve sonuçlara dön düğmeleri vardır. Arama geçmişi, açık/koyu/sistem teması, önbellek temizleme bulunur. Blogspot dışı ana sayfa gezinmeleri ve harici uygulama bağlantıları engellenir. Google arama/çerez doğrulaması ve Blogger görsel sunucuları görüntüleyicide çalışabilir.

## Sınırlar

Tüm Blogspot arşivini veya her görseli bulma garantisi yoktur. Yalnızca Google tarafından indekslenen sonuçlar görüntülenir; özel, silinmiş ve indekslenmemiş içerikler bulunamaz. Özel alan adını kullanan Blogger siteleri kapsam dışıdır. Google doğrulama ekranı gösterebilir veya gömülü tarayıcı erişimini sınırlayabilir. Bu engeller aşılmaz. Görsellerin kaynağı/lisansı blogun koşullarına bağlıdır.

Önceki Openverse, Wikimedia, Pexels, Pixabay, Unsplash, Custom Search API adaptörleri, API anahtarları ekranı ve Pinterest geçişi kaldırıldı. Önceki yerel ızgara, indirici, favori, ses, tarih/çözünürlük filtreleri bu sadeleştirilmiş sürümde bulunmaz. Eski Hive kutuları silinmez; yeni arama geçmişi ayrı tutulur.

## APK

GitHub Actions: Build GorselAra APK → en yeni başarılı çalışma → Artifacts → GorselAra-APK. ZIP'i açıp GorselAra.apk dosyasını yükleyin. Telefonda kaynak yüklemek gerekmez.

Kişisel test derlemesi, release modunda test anahtarıyla imzalanır (imzalama sırları sağlanmışsa o anahtar kullanılır). Önceki APK ile imza farklı olursa Android güncellemeyi reddeder. Eski uygulamayı kaldırmak yerel favorileri/geçmişi/ayarları siler; galeriye indirilmiş dosyaları silmez.

## Geliştirme

Flutter 3.32.8, Dart 3.8, Java 17. `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --release`. Android iskeleti ve Gradle wrapper Actions iş akışında üretilir. Testler arama URL kodlamasını, Blogspot kapsamını, harici bağlantı engelini ve arama sayfası içinde kapsam korumasını doğrular. Fiziksel cihazda web sonuçlarının çalışması ayrıca denenmelidir.

•HAKTAN DEĞİRMENCİ•
