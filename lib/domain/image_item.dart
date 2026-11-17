enum SourceId { openverse, wikimedia, pexels, pixabay, unsplash, google }

extension SourceName on SourceId {
  String get label => const ['Openverse', 'Wikimedia', 'Pexels', 'Pixabay', 'Unsplash', 'Google'][index];
  bool get requiresKey => index >= 2;
}

enum ImageDateKind { uploaded, indexed, published }

class ImageItem {
  final String id, title, thumbnailUrl, imageUrl, pageUrl, creator, license;
  final SourceId source;
  final int? width, height;
  final DateTime? date;
  final ImageDateKind? dateKind;
  final List<String> tags;
  final String? downloadTrackingUrl, creatorUrl, licenseUrl;
  final bool originalAvailable;

  const ImageItem({required this.id, required this.source, required this.title,
    required this.thumbnailUrl, required this.imageUrl, required this.pageUrl,
    this.creator = '', this.license = '', this.width, this.height, this.date,
    this.dateKind, this.tags = const [], this.downloadTrackingUrl,
    this.creatorUrl, this.licenseUrl, this.originalAvailable = false});

  String get key => '${source.name}:$id';
  double get aspectRatio => width != null && height != null && width! > 0 && height! > 0
      ? (width! / height!).clamp(0.55, 1.8).toDouble() : 1.0;

  Map<String, dynamic> toJson() => {
    'id': id, 'source': source.name, 'title': title,
    'thumbnailUrl': thumbnailUrl, 'imageUrl': imageUrl, 'pageUrl': pageUrl,
    'creator': creator, 'license': license, 'width': width, 'height': height,
    'date': date?.toIso8601String(), 'dateKind': dateKind?.name, 'tags': tags,
    'downloadTrackingUrl': downloadTrackingUrl, 'creatorUrl': creatorUrl,
    'licenseUrl': licenseUrl, 'originalAvailable': originalAvailable,
  };

  factory ImageItem.fromJson(Map<String, dynamic> j) => ImageItem(
    id: j['id'] as String, source: SourceId.values.byName(j['source'] as String),
    title: j['title'] as String, thumbnailUrl: j['thumbnailUrl'] as String,
    imageUrl: j['imageUrl'] as String, pageUrl: j['pageUrl'] as String,
    creator: j['creator'] as String? ?? '', license: j['license'] as String? ?? '',
    width: j['width'] as int?, height: j['height'] as int?,
    date: DateTime.tryParse(j['date'] as String? ?? ''),
    dateKind: j['dateKind'] == null ? null : ImageDateKind.values.byName(j['dateKind'] as String),
    tags: List<String>.from(j['tags'] as List? ?? []),
    downloadTrackingUrl: j['downloadTrackingUrl'] as String?,
    creatorUrl: j['creatorUrl'] as String?, licenseUrl: j['licenseUrl'] as String?,
    originalAvailable: j['originalAvailable'] as bool? ?? false,
  );
}
