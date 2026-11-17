import 'package:flutter_test/flutter_test.dart';
import 'package:gorselara/domain/image_item.dart';
import 'package:gorselara/domain/search_filter.dart';

ImageItem image({int? w, int? h, DateTime? date}) => ImageItem(id: '1', source: SourceId.wikimedia,
  title: 'Test', thumbnailUrl: 'https://example.org/t.jpg', imageUrl: 'https://example.org/i.jpg',
  pageUrl: 'https://example.org', width: w, height: h, date: date);
void main() {
  test('4K filter accepts landscape and portrait and rejects short panoramas', () {
    const f = SearchFilter(resolution: Resolution.uhd);
    expect(f.matches(image(w: 3840, h: 2160)), isTrue);
    expect(f.matches(image(w: 2160, h: 3840)), isTrue);
    expect(f.matches(image(w: 6000, h: 500)), isFalse);
    expect(f.matches(image(w: 3839, h: 2160)), isFalse);
    expect(f.matches(image()), isFalse);
  });
  test('date filtering excludes unknown dates and the selected day', () {
    final f = SearchFilter(date: DateTime(2026, 1, 10));
    expect(f.matches(image(date: DateTime.utc(2026, 1, 11))), isTrue);
    expect(f.matches(image(date: DateTime.utc(2026, 1, 10, 23))), isFalse);
    expect(f.matches(image()), isFalse);
    final before = SearchFilter(date: DateTime(2026, 1, 10), direction: DateDirection.before);
    expect(before.matches(image(date: DateTime.utc(2026, 1, 9))), isTrue);
  });
  test('metadata survives local persistence', () {
    final original = image(w: 1920, h: 1080, date: DateTime.utc(2025));
    final restored = ImageItem.fromJson(original.toJson());
    expect(restored.key, original.key);
    expect(restored.width, original.width);
    expect(restored.date, original.date);
  });
}
