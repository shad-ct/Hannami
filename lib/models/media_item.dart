enum MediaType { image, video }

class MediaItem {
  final String id;
  final String filePath;
  final DateTime date;
  final MediaType type;

  const MediaItem({
    required this.id,
    required this.filePath,
    required this.date,
    required this.type,
  });
}
