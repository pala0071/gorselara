import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../domain/image_item.dart';

class ImageTile extends StatelessWidget {
  final ImageItem image;
  final VoidCallback onTap;
  final String heroPrefix;
  const ImageTile({super.key, required this.image, required this.onTap, required this.heroPrefix});
  @override
  Widget build(BuildContext context) => Card(clipBehavior: Clip.antiAlias, margin: EdgeInsets.zero,
    child: InkWell(onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Hero(tag: '$heroPrefix:${image.key}', child: AspectRatio(aspectRatio: image.aspectRatio,
        child: CachedNetworkImage(imageUrl: image.thumbnailUrl, fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 250),
          placeholder: (_, __) => Container(color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.center, child: const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined))))),
      Padding(padding: const EdgeInsets.fromLTRB(10, 9, 10, 4), child: Text(image.title.isEmpty ? image.source.label : image.title,
        maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
      Padding(padding: const EdgeInsets.fromLTRB(10, 0, 10, 10), child: Text(
        '${image.source.label}${image.creator.isEmpty ? '' : ' · ${image.creator}'}', maxLines: 2,
        overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall)),
    ])));
}
