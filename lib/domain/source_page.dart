import 'image_item.dart';

class SourcePage {
  final List<ImageItem> items;
  final String? nextCursor;
  const SourcePage({required this.items, this.nextCursor});
}
