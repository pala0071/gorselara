import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/image_item.dart';
import '../providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final controllers = <String, TextEditingController>{
    for (final key in ['pexels', 'pixabay', 'unsplash', 'google', 'google_cx']) key: TextEditingController(),
  };
  bool ready = false, saving = false;
  String? error;
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    try {
      for (final entry in controllers.entries) {
        final value = await ref.read(credentialProvider).read(entry.key);
        if (!mounted) return;
        entry.value.text = value;
      }
      if (mounted) setState(() => ready = true);
    } catch (_) { if (mounted) setState(() => error = 'Secure storage'); }
  }
  @override
  void dispose() { for (final c in controllers.values) { c.dispose(); } super.dispose(); }
  Future<void> save() async {
    setState(() => saving = true);
    final s = ref.read(stringsProvider);
    try {
      for (final entry in controllers.entries) { await ref.read(credentialProvider).write(entry.key, entry.value.text); }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('API anahtarları kaydedildi.', 'API keys saved.'))));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('Anahtarlar kaydedilemedi.', 'Could not save API keys.'))));
    } finally { if (mounted) setState(() => saving = false); }
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider), s = ref.watch(stringsProvider);
    return Scaffold(appBar: AppBar(title: Text(s.t('Ayarlar', 'Settings'))), body: ListView(padding: const EdgeInsets.all(20), children: [
      Text(s.t('Görünüm', 'Appearance'), style: Theme.of(context).textTheme.titleLarge),
      DropdownButtonFormField<ThemeMode>(value: state.theme, decoration: InputDecoration(labelText: s.t('Tema', 'Theme')),
        items: ThemeMode.values.map((m) => DropdownMenuItem(value: m,
          child: Text(s.t(['Sistem', 'Açık', 'Koyu'][m.index], ['System', 'Light', 'Dark'][m.index])))).toList(),
        onChanged: (v) { if (v != null) ref.read(settingsProvider.notifier).update(theme: v); }),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: state.language, decoration: InputDecoration(labelText: s.t('Dil', 'Language')),
        items: const [DropdownMenuItem(value: 'tr', child: Text('Türkçe')), DropdownMenuItem(value: 'en', child: Text('English'))],
        onChanged: (v) { if (v != null) ref.read(settingsProvider.notifier).update(language: v); }),
      const SizedBox(height: 28), Text(s.t('API anahtarları', 'API keys'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8), Text(s.t('Openverse ve Wikimedia anahtarsızdır. Anahtarlar Android güvenli depolamasında saklanır; kaynak koduna yazılmaz.',
        'Openverse and Wikimedia require no keys. Keys are stored in Android secure storage, not source code.')),
      if (!ready && error == null) const LinearProgressIndicator(),
      if (error != null) ListTile(title: Text(s.t('Güvenli depolama okunamadı.', 'Could not read secure storage.')),
        trailing: IconButton(onPressed: () { setState(() => error = null); load(); }, icon: const Icon(Icons.refresh))),
      for (final entry in controllers.entries) Padding(padding: const EdgeInsets.only(top: 14), child: TextField(
        controller: entry.value, enabled: ready && !saving, obscureText: entry.key != 'google_cx',
        autocorrect: false, enableSuggestions: false,
        decoration: InputDecoration(border: const OutlineInputBorder(), labelText: entry.key == 'google_cx' ? 'Google Search Engine ID (cx)' : '${SourceId.values.byName(entry.key).label} API key'))),
      const SizedBox(height: 12), FilledButton(onPressed: ready && !saving ? save : null,
        child: Text(saving ? s.t('Kaydediliyor…', 'Saving…') : s.t('Anahtarları kaydet', 'Save keys'))),
      const SizedBox(height: 12), Text(s.t('Google Custom Search yeni müşterilere kapalıdır. Mevcut erişim 1 Ocak 2027 tarihinde sona erecek. Unsplash kullanımı için sağlayıcı koşullarını ve uygulama onayını kontrol edin.',
        'Google Custom Search is closed to new customers; existing access ends January 1, 2027. Check Unsplash terms and app approval before enabling it.')),
      for (final link in const {
        'Pexels': 'https://www.pexels.com/api/', 'Pixabay': 'https://pixabay.com/api/docs/',
        'Unsplash': 'https://unsplash.com/developers', 'Google': 'https://developers.google.com/custom-search/v1/overview',
      }.entries) ListTile(title: Text(link.key), trailing: const Icon(Icons.open_in_new), onTap: () async {
        try { if (!await launchUrl(Uri.parse(link.value), mode: LaunchMode.externalApplication)) throw StateError('URL'); }
        catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('Bağlantı açılamadı.', 'Could not open link.')))); }
      }),
      const Divider(),
      ListTile(leading: const Icon(Icons.cleaning_services_outlined), title: Text(s.t('Önbelleği temizle', 'Clear cache')),
        subtitle: Text(s.t('Favoriler, anahtarlar ve geçmiş korunur.', 'Keeps favorites, keys and history.')), onTap: () async {
          try {
            await DefaultCacheManager().emptyCache(); await ref.read(storeProvider).cache.clear();
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('Önbellek temizlendi.', 'Cache cleared.'))));
          } catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('Önbellek temizlenemedi.', 'Could not clear cache.')))); }
        }),
      const SizedBox(height: 16), Text(s.t('İndirmeyi tamamlayana kadar uygulamayı açık tutun. İşletim sistemi uygulamayı kapatırsa indirme devam etmez. Görsellerin lisans ve atıf koşulları kaynak sayfasında geçerlidir.',
        'Keep the app open until downloads finish. Downloads do not survive process termination. Source licenses and attribution requirements apply.')),
      const SizedBox(height: 28), const Center(child: Text('•HAKTAN DEĞİRMENCİ•')),
    ]));
  }
}
