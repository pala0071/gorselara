import 'dart:math';
import 'image_item.dart';

enum Resolution { all, hd, fullHd, uhd }
enum DateDirection { after, before }

class SearchFilter {
  final Resolution resolution;
  final DateTime? date;
  final DateDirection direction;
  const SearchFilter({this.resolution = Resolution.all, this.date,
    this.direction = DateDirection.after});

  bool matches(ImageItem image) {
    if (resolution != Resolution.all) {
      if (image.width == null || image.height == null) return false;
      final long = max(image.width!, image.height!);
      final short = min(image.width!, image.height!);
      final minimum = switch (resolution) {
        Resolution.hd => (1280, 720),
        Resolution.fullHd => (1920, 1080),
        Resolution.uhd => (3840, 2160),
        Resolution.all => (0, 0),
      };
      if (long < minimum.$1 || short < minimum.$2) return false;
    }
    if (date != null) {
      if (image.date == null) return false;
      final d = image.date!.toUtc();
      final imageDay = DateTime.utc(d.year, d.month, d.day);
      final selectedDay = DateTime.utc(date!.year, date!.month, date!.day);
      return direction == DateDirection.after
          ? imageDay.isAfter(selectedDay) : imageDay.isBefore(selectedDay);
    }
    return true;
  }
}
