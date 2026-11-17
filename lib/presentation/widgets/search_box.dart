import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers.dart';

class SearchBox extends ConsumerStatefulWidget {
  const SearchBox({super.key});
  @override
  ConsumerState<SearchBox> createState() => _SearchBoxState();
}
class _SearchBoxState extends ConsumerState<SearchBox> {
  final controller = TextEditingController();
  final focus = FocusNode();
  final speech = SpeechToText();
  bool listening = false, suggestions = false;
  @override
  void initState() {
    super.initState();
    focus.addListener(() { if (mounted) setState(() => suggestions = focus.hasFocus); });
  }
  void submit(String q) {
    controller.text = q;
    focus.unfocus();
    setState(() => suggestions = false);
    ref.read(searchProvider.notifier).search(q);
  }
  Future<void> openPinterest() async {
    final s = ref.read(stringsProvider);
    final query = controller.text.trim();
    if (query.isEmpty) {
      focus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        s.t('Önce aramak istediğin kelimeyi yaz.', 'Enter a search term first.'))));
      return;
    }
    focus.unfocus();
    final uri = Uri.https('www.pinterest.com', '/search/pins/', {'q': query});
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened) throw StateError('Unable to open Pinterest');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        s.t('Pinterest açılamadı. Tarayıcını kontrol edip tekrar dene.',
          'Could not open Pinterest. Check your browser and try again.')),
        action: SnackBarAction(label: s.t('Yeniden dene', 'Retry'), onPressed: openPinterest)));
    }
  }
  Future<void> dictate() async {
    final s = ref.read(stringsProvider);
    if (listening) { await speech.stop(); if (mounted) setState(() => listening = false); return; }
    try {
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('Sesli arama için mikrofon izni gerekli.', 'Microphone permission is required.'))));
        return;
      }
      final ready = await speech.initialize(onStatus: (status) {
        if (mounted) setState(() => listening = status == 'listening');
      }, onError: (_) {
        if (!mounted) return;
        setState(() => listening = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('Ses algılanamadı. Tekrar deneyin.', 'Could not recognize speech. Please retry.'))));
      });
      if (!ready) throw StateError('Speech unavailable');
      await speech.listen(localeId: s.language == 'tr' ? 'tr_TR' : 'en_US', onResult: (r) {
        if (!mounted) return;
        setState(() => controller.text = r.recognizedWords);
        if (r.finalResult && r.recognizedWords.trim().isNotEmpty) submit(r.recognizedWords);
      });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('Bu cihazda ses tanıma kullanılamıyor.', 'Speech recognition is unavailable on this device.'))));
    }
  }
  @override
  void dispose() { speech.cancel(); controller.dispose(); focus.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    ref.watch(libraryProvider);
    final history = ref.read(storeProvider).searches.where((q) => q.toLowerCase().contains(controller.text.toLowerCase())).take(5).toList();
    return Column(children: [
      TextField(controller: controller, focusNode: focus, textInputAction: TextInputAction.search,
        onSubmitted: submit, onChanged: (_) => setState(() => suggestions = true),
        decoration: InputDecoration(hintText: s.t('Ne arıyorsun?', 'What are you looking for?'),
          prefixIcon: IconButton(onPressed: () => submit(controller.text), icon: const Icon(Icons.search)),
          suffixIcon: IconButton(tooltip: s.t('Sesle ara', 'Voice search'), onPressed: dictate,
            icon: Icon(listening ? Icons.mic : Icons.mic_none, color: listening ? Colors.red : null)),
          filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none))),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: openPinterest,
        icon: const Icon(Icons.open_in_new),
        label: Text(s.t('Pinterest’te ara', 'Search on Pinterest')))),
      Text(s.t('Anahtar gerekmez · Pinterest uygulamasında veya tarayıcıda açılır.',
        'No API key · Opens in Pinterest or your browser.'),
        textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      if (suggestions && history.isNotEmpty) Card(child: Column(children: history.map((q) => ListTile(
        dense: true, leading: const Icon(Icons.history), title: Text(q), onTap: () => submit(q))).toList())),
    ]);
  }
}
