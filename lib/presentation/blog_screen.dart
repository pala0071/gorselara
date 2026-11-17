import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../domain/blog_search.dart';
import 'preferences.dart';

class BlogScreen extends ConsumerStatefulWidget {
  const BlogScreen({super.key});
  @override
  ConsumerState<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends ConsumerState<BlogScreen> {
  final text = TextEditingController();
  WebViewController? browser;
  String query = '', host = '';
  String? error;
  int progress = 100;
  bool back = false, forward = false;

  @override
  void initState() { super.initState(); initialize(); }

  Future<void> initialize() async {
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.enableZoom(true);
      await controller.setNavigationDelegate(NavigationDelegate(
        onProgress: (value) { if (mounted) setState(() => progress = value); },
        onPageStarted: (url) {
          if (mounted) setState(() { host = Uri.tryParse(url)?.host ?? ''; error = null; });
        },
        onPageFinished: (_) => updateNavigation(),
        onWebResourceError: (failure) {
          if (mounted && failure.isForMainFrame == true) {
            setState(() { error = 'Sayfa yüklenemedi. İnternet bağlantını kontrol edip yeniden dene.'; progress = 100; });
          }
        },
        onNavigationRequest: (request) {
          final uri = Uri.tryParse(request.url);
          if (uri == null || !BlogSearch.allowed(uri)) {
            if (request.isMainFrame) message('Bu bağlantı Blogspot kapsamı dışında veya desteklenmiyor.');
            return NavigationDecision.prevent;
          }
          if (request.isMainFrame) {
            final corrected = BlogSearch.restrictedSearch(uri);
            if (corrected != null) {
              controller.loadRequest(corrected).catchError((Object _) {
                message('Arama açılamadı. Yeniden deneyin.');
              });
              return NavigationDecision.prevent;
            }
          }
          return NavigationDecision.navigate;
        },
      ));
      if (mounted) setState(() { browser = controller; error = null; });
    } catch (_) {
      if (mounted) setState(() => error = 'Web görüntüleyici başlatılamadı. Android System WebView bileşenini güncelleyip yeniden dene.');
    }
  }

  void message(String value) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  Future<void> updateNavigation() async {
    final controller = browser;
    if (controller == null) return;
    try {
      final canBack = await controller.canGoBack();
      final canForward = await controller.canGoForward();
      if (mounted) setState(() { back = canBack; forward = canForward; });
    } catch (_) { /* Navigation can change while the widget is closing. */ }
  }

  Future<void> search([String? value]) async {
    final q = BlogSearch.cleanQuery(value ?? text.text);
    if (q.isEmpty) { message('Aramak istediğin kelimeyi yaz.'); return; }
    FocusManager.instance.primaryFocus?.unfocus();
    text.text = q;
    setState(() { query = q; error = null; progress = 0; });
    if (browser == null) await initialize();
    if (!mounted || browser == null) return;
    try {
      await browser!.loadRequest(BlogSearch.url(q));
    } catch (_) {
      if (mounted) setState(() { error = 'Arama açılamadı. Yeniden dene.'; progress = 100; });
      return;
    }
    try {
      final history = ref.read(historyBox);
      await history.delete(q.toLowerCase());
      await history.put(q.toLowerCase(), q);
      while (history.length > 100) { await history.deleteAt(0); }
    } catch (_) { message('Arama geçmişe kaydedilemedi.'); }
  }

  Future<void> historySheet() async {
    final entries = ref.read(historyBox).values.toList().reversed.toList();
    final selected = await showModalBottomSheet<String>(context: context, showDragHandle: true,
      builder: (context) => SafeArea(child: ListView(shrinkWrap: true, children: [
        const ListTile(title: Text('Blogspot arama geçmişi')),
        if (entries.isEmpty) const ListTile(title: Text('Henüz arama yok.')),
        for (final q in entries) ListTile(leading: const Icon(Icons.history), title: Text(q),
          onTap: () => Navigator.pop(context, q)),
      ])));
    if (mounted && selected != null) await search(selected);
  }

  Future<void> settingsSheet() async {
    await showModalBottomSheet<void>(context: context, showDragHandle: true,
      builder: (context) => Consumer(builder: (context, ref, _) => SafeArea(child: ListView(
        shrinkWrap: true, padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), children: [
          const Text('Ayarlar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          DropdownButton<ThemeMode>(isExpanded: true, value: ref.watch(themeProvider),
            items: const [DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem teması')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Açık tema')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Koyu tema'))],
            onChanged: (v) async {
              if (v == null) return;
              try { await ref.read(themeProvider.notifier).change(v); }
              catch (_) { message('Tema kaydedilemedi.'); }
            }),
          ListTile(leading: const Icon(Icons.cleaning_services_outlined), title: const Text('Web önbelleğini temizle'),
            onTap: () async {
              try { await browser?.clearCache(); message('Önbellek temizlendi.'); }
              catch (_) { message('Önbellek temizlenemedi.'); }
            }),
          ListTile(leading: const Icon(Icons.history), title: const Text('Arama geçmişini temizle'),
            onTap: () async {
              final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
                title: const Text('Arama geçmişi silinsin mi?'),
                actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Vazgeç')),
                  FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Sil'))]));
              if (confirmed != true || !mounted) return;
              try { await this.ref.read(historyBox).clear(); message('Arama geçmişi temizlendi.'); }
              catch (_) { message('Geçmiş temizlenemedi.'); }
            }),
          const Divider(),
          const Text('Yalnızca blogspot.com sitelerinde görsel arar. Google görsel sonuçları uygulama içindeki web görüntüleyicide açılır. API anahtarı gerekmez. İndekslenmemiş veya özel içerikler bulunamaz; Google doğrulama isteyebilir. Google hesabına giriş zorunlu değildir.'),
          const SizedBox(height: 16),
          const Text('Bu sürüm web sonuçlarını gösterir. Önceki sürümün yerel görsel ızgarası, galeriye indirme, favori ve çözünürlük/tarih filtreleri bu ekranda bulunmaz.'),
          const SizedBox(height: 24), const Center(child: Text('•HAKTAN DEĞİRMENCİ•')),
        ]))));
  }

  @override
  void dispose() { text.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !back,
    onPopInvokedWithResult: (didPop, _) async {
      if (!didPop && browser != null) await browser!.goBack();
    },
    child: Scaffold(appBar: AppBar(title: const Text('GörselAra'), actions: [
      IconButton(tooltip: 'Arama geçmişi', onPressed: historySheet, icon: const Icon(Icons.history)),
      IconButton(tooltip: 'Ayarlar', onPressed: settingsSheet, icon: const Icon(Icons.settings_outlined)),
    ]), body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 6), child: TextField(
        controller: text, textInputAction: TextInputAction.search, onSubmitted: search,
        decoration: InputDecoration(hintText: 'Blogspot görsellerinde ara', filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          prefixIcon: const Icon(Icons.image_search), suffixIcon: IconButton(tooltip: 'Ara',
            onPressed: search, icon: const Icon(Icons.arrow_forward))))),
      const Padding(padding: EdgeInsets.only(bottom: 6), child: Text('Yalnızca Blogspot • Anahtarsız • Uygulama içinde')),
      if (query.isNotEmpty) SizedBox(height: 44, child: Row(children: [
        IconButton(tooltip: 'Geri', onPressed: back ? () => browser?.goBack() : null, icon: const Icon(Icons.arrow_back)),
        IconButton(tooltip: 'İleri', onPressed: forward ? () => browser?.goForward() : null, icon: const Icon(Icons.arrow_forward)),
        Expanded(child: Text(host, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall)),
        IconButton(tooltip: 'Sonuçlara dön', onPressed: () => search(query), icon: const Icon(Icons.grid_view)),
        IconButton(tooltip: 'Yenile', onPressed: () async {
          try { await browser?.reload(); } catch (_) { message('Sayfa yenilenemedi.'); }
        }, icon: const Icon(Icons.refresh)),
      ])),
      if (progress < 100 && error == null) LinearProgressIndicator(value: progress / 100),
      Expanded(child: error != null ? Center(child: Padding(padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off, size: 44), const SizedBox(height: 12), Text(error!, textAlign: TextAlign.center),
          const SizedBox(height: 16), FilledButton(onPressed: () => query.isEmpty ? initialize() : search(query),
            child: const Text('Yeniden dene')),
        ]))) : query.isEmpty ? const Center(child: Padding(padding: EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.travel_explore, size: 72), SizedBox(height: 20),
            Text('Blogspot’ta görsel keşfet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            SizedBox(height: 12), Text('Bir kelime yaz. Blogspot sitelerinin indekslenmiş görselleri burada açılsın.', textAlign: TextAlign.center),
          ]))) : browser == null ? const Center(child: CircularProgressIndicator()) : WebViewWidget(controller: browser!)),
    ]))),
  );
}
