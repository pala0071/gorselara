# GörselAra

Flutter / Dart Android görsel arama projesi. Paket: `com.gorselara.app`.

## Teslim ve doğrulama durumu

Release APK, GitHub Actions üzerinde başarıyla derlendi. Flutter analizinde hiçbir sorun yok. Altı otomatik testin tamamı başarılı.
Fiziksel Android cihaz veya emülatör testi yapılmadı. Anahtarlı kaynaklar kullanıcı
anahtarları olmadan canlı olarak doğrulanmadı. Wikimedia canlı arama isteği sonuç verdi;
Openverse bu geliştirme ortamındaki denemede HTTP 403 döndürdü.

- Derlenen kaynak commit: `4d91b5292202490885cc1c494855692a8238a90d`
- Başarılı derleme: https://github.com/pala0071/gorselara/actions/runs/44140286230
- APK boyutu: 58.121.779 bayt
- APK SHA-256: `83d27170de6d058f26d9b4ce3640237e5d1dffd418601561f5af79b5ff533560`
- İmza: kişisel deneme için debug anahtarıyla imzalanmış release derleme.

Bu depodaki pubspec.lock, başarılı derlemede çözülmüş bağımlılıkları sabitler.

## Mimari

- domain: sağlayıcıdan bağımsız görsel modeli, filtre, sayfa ve ImageSource sözleşmesi.
- data: altı kaynak, güvenli anahtarlar, Hive, 24 saatlik API önbelleği, galeriye indirme.
- presentation: Riverpod denetleyicileri, Material 3 ekranlar, masonry ızgara ve görüntüleyici.
- core: Türkçe/İngilizce mesajlar, hatalar ve yardımcılar.

Kütüphane: favoriler, son 100 arama ve tamamlanan indirmeler. API yanıtları en fazla
250 kayıt ve 24 saat saklanır. Anahtarlar Hive'a yazılmaz; FlutterSecureStorage kullanılır.
Bir kaynağın hata vermesi diğer kaynağın sonuçlarını silmez. Sayfalama her kaynak için
ayrıdır. Sonuçlar kaynaklar arasında dönüşümlü karıştırılır ve akışta tekrarlar elenir.

## Kullanım

1. Anahtarsız Openverse ve Wikimedia varsayılan olarak seçilidir.
2. Kelime yazıp klavyedeki arama düğmesine veya büyütece basın.
3. Çiplerden kaynak ekleyin. Anahtar gereken kaynakları Ayarlar ekranından yapılandırın.
4. Filtreler düğmesinden tarih ve çözünürlük belirleyin.
5. Görsele dokunun; iki parmakla veya çift dokunmayla yakınlaştırın, yana kaydırın.
6. Üç nokta menüsünden indirin, paylaşın, kaynağı açın, favoriye ekleyin veya benzerlerini arayın.

## Gerçek sınırlamalar

- Tarih filtresi istemcidedir. Bilinmeyen tarihler dışlanır ve sayılır. Seçilen gün dahil
  değildir. UTC takvim günü kullanılır. Openverse indeksleme, Wikimedia dosya sürümünün
  yüklenme, Unsplash yayımlanma tarihini gösterir. Fotoğraf çekim tarihi vaat edilmez.
  Pexels, Pixabay ve Google arama yanıtlarında güvenilir ortak tarih yoksa tarih null kalır.
- HD 1280×720, Full HD 1920×1080, 4K 3840×2160 alt sınırlarını yön bağımsız uygular.
  Ölçüler kaynak metadatasına aittir. Özellikle Pixabay/Openverse için indirilen dosya
  kaynakta bildirilen orijinal ölçülerden küçük olabilir; arayüz bunu belirtir.
- Openverse için orijinal kalite garanti edilmez. Pixabay imageURL sağlıyorsa orijinal,
  sağlamıyorsa largeImageURL kullanılır. Google için orijinal garanti edilmez.
- Openverse ilişkili görseller uç noktasını kullanır. Diğerlerinde benzerlik başlık/etiket
  sorgusudur; görsel gömme modeli veya gerçek tersine görsel arama değildir.
- İndirmeler Dio üzerinden uygulama sürecinde yapılır. Uygulamayı açık tutun; kalıcı
  arka plan servisi/WorkManager ve süreç öldürülünce devam ettirme bu sürümde yoktur.
- JPEG, PNG, GIF ve WebP indirilebilir. Dosya imzası kontrol edilir. SVG, TIFF, AVIF
  gibi diğer biçimler galeri uyumluluğu için reddedilir. Dosya başına sınır 150 MiB'dir.
- Android 13/14'te başka fotoğrafları okumak için izin istenmez. Bildirim ve mikrofon
  izni kullanım sırasında istenir. Eski Android depolama iznini Gal yönetir.
- Ses tanıma cihazın konuşma hizmetine bağlıdır ve o hizmet internet gerektirebilir.
- Kaynak servis kesintileri, URL süreleri, lisans şartları ve API kotaları uygulama dışında yönetilir.
- Unsplash hotlink URL'leri korunur; indirme/paylaşma için download_location çağrılır.
  Atıf bağlantıları bulunur. Arama/indirme odaklı bir uygulama Unsplash'ın uygulama
  kısıtlarıyla çelişebilir; sağlayıcıdan izin alınmadan herkese açık yayın yapmayın.
- Google Custom Search JSON API yeni müşterilere kapalıdır. Resmî açıklamadaki mevcut
  müşteri hizmet bitişi 1 Ocak 2027'dir. Bu bağdaştırıcı sadece mevcut erişim içindir.

## Telefonda bilgisayarsız APK derleme

Aşağıdaki yöntem telefonun klasör yüklemesini gerektirmez: ZIP'i olduğu gibi yüklersiniz,
GitHub Actions ZIP'i açar. ZIP tek başına workflow başlatmaz; workflow dosyası ayrıca gerekir.

1. `GorselAra-Source.zip` dosyasını telefona indirin. Adını değiştirmeyin.
2. Chrome ile https://github.com adresine giriş yapın. Gerekirse Masaüstü sitesi seçeneğini açın.
3. https://github.com/new sayfasından `gorselara` adında bir repo oluşturun. Tercihen Private
   seçin. README ekleme seçeneğini açın; böylece `main` dalı oluşur.
4. Repo içinden Add file → Upload files ile `GorselAra-Source.zip` dosyasını kök dizine
   yükleyin ve Commit changes yapın. ZIP'i açıp tek tek yüklemeniz gerekmez.
5. Telefonda ZIP'i Dosyalar uygulamasıyla ayrıca açın. İçindeki
   `.github/workflows/build.yml` metnini bir metin düzenleyici ile açıp tamamını kopyalayın.
   Noktayla başlayan .github görünmüyorsa gizli dosyaları göster seçeneğini açın.
   Alternatif olarak teslim edilen TUM-KODLAR.md içindeki aynı dosya bölümünü kullanın.
6. GitHub reposunda Add file → Create new file seçin. Dosya adı kutusuna
   `.github/workflows/build.yml` yazın, içeriğini yapıştırın ve Commit changes yapın.
7. Actions sekmesini açın. İstenirse Actions kullanımını etkinleştirin.
8. Build GorselAra APK → Run workflow → main → Run workflow seçin.
9. İşlemin başarılı olmasını bekleyin. Kırmızı hata varsa ilgili adımın günlüğünü açın;
   kaynakların derlenebilirliği burada doğrulanacaktır. Hata çıktısını geliştiriciyle paylaşın.
10. Başarılı çalıştırmanın altındaki Artifacts bölümünde GorselAra-APK'ya dokunun.
11. İnen ZIP'i açın; içindeki GorselAra.apk dosyasına dokunun. Android isterse bu
    dosyayı açtığınız uygulamaya bilinmeyen uygulama yükleme izni verin.
12. GorselAra-Build-Metadata içindeki pubspec.lock dosyasını sonraki kaynak paketinin
    köküne eklemek dolaylı bağımlılıkların da sabitlenmesini sağlar.

GitHub Actions kullanım kotası hesabınıza/repo türüne bağlıdır. Yeterli kotanız olmadan
ücretsiz sınırsız derleme vaat edilmez. API anahtarlarını GitHub dosyalarına yazmayın.

## İmzalama

Secret verilmezse CI debug anahtarıyla imzalanmış bir release APK üretir. Bu kişisel deneme
amaçlıdır; Play Store yayını için uygun imza yönetimi değildir. Farklı CI çalıştırmaları farklı
anahtar üretebilir; mevcut uygulamanın üzerine kurulum reddedilebilir. Eski uygulamayı silmek
favorileri/anahtarları/geçmişi siler. Kalıcı güncellemeler için aynı release anahtarını kullanın.

Kendi anahtarınız varsa GitHub Settings → Secrets and variables → Actions içinde:

- ANDROID_KEYSTORE_BASE64: JKS dosyanızın base64 içeriği
- ANDROID_KEYSTORE_PASSWORD: keystore şifresi
- ANDROID_KEY_ALIAS: anahtar alias'ı
- ANDROID_KEY_PASSWORD: anahtar şifresi

İmza anahtarını kaynak koduna veya halka açık artifact'e eklemeyin.

## API bağlantıları

| Kaynak | Bağlantı | Gereken |
|---|---|---|
| Openverse | https://api.openverse.org/v1/ | Anahtarsız, anonim kota |
| Wikimedia Commons | https://commons.wikimedia.org/w/api.php | Anahtarsız |
| Pexels | https://www.pexels.com/api/ | Hesap ve API key; mevcut kayıt/uygulama koşullarına bağlı |
| Pixabay | https://pixabay.com/api/docs/ | Hesap ve API key |
| Unsplash | https://unsplash.com/developers | Uygulama kaydı, Access Key ve kullanım koşullarına uygunluk |
| Google | https://developers.google.com/custom-search/v1/overview | Yalnız mevcut müşteri: API key ve cx |

Unsplash Secret Key yerine Access Key girin. Google'da ücretsiz kota yalnız mevcut uygun
müşteriler içindir; bu uygulama ücretli kota satın almaz. Lisans ve kullanıcı atfı
kaynak sayfasına göre değerlendirilmelidir; indirme yeniden kullanım hakkı sağlamaz.

## Yerel geliştirme

Flutter 3.32.8 ve JDK 17 ile aşağıdaki yöntem Android wrapper'ını üretir:

```bash
flutter create --platforms=android --org com.gorselara --project-name gorselara --android-language kotlin --no-pub fresh_project
```

Ardından bu paketin dosyalarını fresh_project içine kopyalayın; oluşturulan local.properties
ve Gradle wrapper dosyalarını koruyun. Gradle wrapper sürümü 8.10.2 olmalıdır. CI bunları
otomatik yapar. Proje içinde flutter pub get, flutter analyze, flutter test ve
flutter build apk --release çalıştırılır.
