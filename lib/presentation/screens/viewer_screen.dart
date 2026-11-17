import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/app_exception.dart';
import '../../core/utils.dart';
import '../../domain/image_item.dart';
import '../providers.dart';

enum ViewerAction { download, share, source, favorite, copy, similar }

class ViewerScreen extends ConsumerStatefulWidget {
  final List<ImageItem> images;
  final int initialIndex;
  final String heroPrefix;
  const ViewerScreen({super.key, required this.images, required this.initialIndex, required this.heroPrefix});
  @override
  ConsumerState<ViewerScreen> createState() => _ViewerScreenState();
}
class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  late int index;
  late PageController pages;
  bool sharing = false;
  @override
  void initState() { super.initState(); index = widget.initialIndex; pages = PageController(initialPage: index); }
  @override
  void dispose() { pages.dispose(); super.dispose(); }
  void message(String value) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value))); }
  Future<void> open(String url) async {
    if (!webUrl(url) || !await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw const AppException(FailureKind.invalid);
    }
  }
  Future<void> action(ViewerAction action) async {
    final image = widget.images[index], s = ref.read(stringsProvider);
    try {
      switch (action) {
        case ViewerAction.download:
          if (ref.read(downloadProvider).busy) { message(s.t('Bir indirme zaten devam ediyor.', 'A download is already running.')); return; }
          await ref.read(downloadProvider.notifier).save(image, s);
          ref.read(libraryProvider.notifier).refresh();
          message(s.t('Pictures/GörselAra klasörüne kaydedildi.', 'Saved to Pictures/GörselAra.'));
        case ViewerAction.share:
          if (sharing) return;
          setState(() => sharing = true);
          File? file;
          try {
            file = await ref.read(downloadServiceProvider).fetch(image, (_) {});
            if (!mounted) return;
            final box = context.findRenderObject() as RenderBox?;
            await Share.shareXFiles([XFile(file.path)], text: '${image.creator} · ${image.source.label}\n${image.pageUrl}',
              sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size);
          } finally { if (file != null && await file.exists()) await file.delete(); if (mounted) setState(() => sharing = false); }
        case ViewerAction.source:
          await open(image.pageUrl);
        case ViewerAction.favorite:
          await ref.read(libraryProvider.notifier).toggle(image);
        case ViewerAction.copy:
          await Clipboard.setData(ClipboardData(text: image.imageUrl));
          message(s.t('Bağlantı kopyalandı.', 'Link copied.'));
        case ViewerAction.similar:
          ref.read(searchProvider.notifier).search(image.title.isEmpty ? image.tags.join(' ') : image.title,
            selected: {image.source}, similar: image);
          if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) { message(s.error(AppException.from(e))); }
  }
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider), download = ref.watch(downloadProvider);
    ref.watch(libraryProvider);
    final image = widget.images[index];
    final favorite = ref.read(storeProvider).isFavorite(image);
    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white,
        title: Text('${index + 1} / ${widget.images.length}'), actions: [
          PopupMenuButton<ViewerAction>(onSelected: action, itemBuilder: (_) => [
            PopupMenuItem(value: ViewerAction.download, child: Text(image.originalAvailable
              ? s.t('İndir (orijinal kalite)', 'Download (original)') : s.t('İndir (erişilebilir en yüksek kalite)', 'Download (best available)'))),
            PopupMenuItem(value: ViewerAction.share, child: Text(s.t('Paylaş', 'Share'))),
            PopupMenuItem(value: ViewerAction.source, child: Text(s.t('Kaynağı aç', 'Open source'))),
            PopupMenuItem(value: ViewerAction.favorite, child: Text(favorite ? s.t('Favorilerden çıkar', 'Remove favorite') : s.t('Favorilere ekle', 'Add favorite'))),
            PopupMenuItem(value: ViewerAction.copy, child: Text(s.t('Bağlantıyı kopyala', 'Copy link'))),
            PopupMenuItem(value: ViewerAction.similar, child: Text(s.t('Benzer görselleri göster', 'Show similar images'))),
          ]),
        ]),
      body: SafeArea(child: Column(children: [
        if (download.busy || sharing) LinearProgressIndicator(value: sharing ? null : download.progress),
        Expanded(child: PhotoViewGallery.builder(pageController: pages, itemCount: widget.images.length,
          onPageChanged: (value) => setState(() => index = value),
          loadingBuilder: (_, event) => const Center(child: CircularProgressIndicator()),
          builder: (_, i) {
            final item = widget.images[i];
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(item.imageUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: '${widget.heroPrefix}:${item.key}'),
              minScale: PhotoViewComputedScale.contained, maxScale: PhotoViewComputedScale.contained * 5,
              errorBuilder: (_, __, ___) => Center(child: Text(s.t('Görsel yüklenemedi. Kaynağı açmayı deneyin.',
                'Could not load image. Try opening the source.'), style: const TextStyle(color: Colors.white))),
            );
          })),
        Container(width: double.infinity, color: const Color(0xFF141A18), padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(image.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Wrap(spacing: 8, children: [
              TextButton(onPressed: () async { try { await open(image.pageUrl); } catch (e) { message(s.error(AppException.from(e))); } }, child: Text(image.source.label)),
              if (image.creator.isNotEmpty) TextButton(onPressed: () async {
                try { await open(webUrl(image.creatorUrl ?? '') ? image.creatorUrl! : image.pageUrl); }
                catch (e) { message(s.error(AppException.from(e))); }
              }, child: Text(image.creator)),
            ]),
            Text('${image.width ?? '?'} × ${image.height ?? '?'} · ${image.license}', style: const TextStyle(color: Colors.white70)),
            if (image.date != null) Text('${switch (image.dateKind) {
              ImageDateKind.indexed => s.t('İndekslenme', 'Indexed'),
              ImageDateKind.uploaded => s.t('Yüklenme', 'Uploaded'),
              _ => s.t('Yayımlanma', 'Published'),
            }}: ${image.date!.toIso8601String().split('T').first}', style: const TextStyle(color: Colors.white70)),
            if (!image.originalAvailable) Text(s.t('Orijinal dosya garanti değil; kaynağın sunduğu dosya indirilir.',
              'Original file not guaranteed; downloads use the file offered by the source.'), style: const TextStyle(color: Colors.amber, fontSize: 11)),
          ])),
      ])));
  }
}
