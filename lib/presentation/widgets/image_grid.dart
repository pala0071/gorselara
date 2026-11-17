import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../domain/image_item.dart';
import '../screens/viewer_screen.dart';
import 'image_tile.dart';

class ImageGrid extends StatelessWidget {
  final List<ImageItem> images;
  final String heroPrefix;
  const ImageGrid({super.key, required this.images, required this.heroPrefix});
  @override
  Widget build(BuildContext context) => SliverMasonryGrid.count(
    crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
    mainAxisSpacing: 12, crossAxisSpacing: 12,
    childCount: images.length, itemBuilder: (context, index) => ImageTile(
      image: images[index], heroPrefix: heroPrefix, onTap: () => Navigator.push(context,
        MaterialPageRoute<void>(builder: (_) => ViewerScreen(images: List.unmodifiable(images),
          initialIndex: index, heroPrefix: heroPrefix)))));
}
