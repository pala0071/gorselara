import 'image_item.dart';

class DownloadRecord {
  final ImageItem image;
  final DateTime savedAt;
  final String fileName;
  const DownloadRecord({required this.image, required this.savedAt, required this.fileName});
  Map<String, dynamic> toJson() => {
    'image': image.toJson(), 'savedAt': savedAt.toIso8601String(), 'fileName': fileName,
  };
  factory DownloadRecord.fromJson(Map<String, dynamic> j) => DownloadRecord(
    image: ImageItem.fromJson(Map<String, dynamic>.from(j['image'] as Map)),
    savedAt: DateTime.parse(j['savedAt'] as String), fileName: j['fileName'] as String);
}
