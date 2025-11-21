class DiaryEntry {
  final String id;
  final String title;
  final String content;
  final DateTime dateTime; // precise date & time
  final String mood;
  final List<String> imagePaths; // stored local file paths
  final List<String> tags;
  final double? latitude;
  final double? longitude;
  final String? weatherSummary; // e.g. "18°C Clear"
  final String? placeName; // e.g. "Paris, France"

  const DiaryEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    required this.mood,
    this.imagePaths = const [],
    this.tags = const [],
    this.latitude,
    this.longitude,
    this.weatherSummary,
    this.placeName,
  });

  DiaryEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? dateTime,
    String? mood,
    List<String>? imagePaths,
    List<String>? tags,
    double? latitude,
    double? longitude,
    String? weatherSummary,
    String? placeName,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      dateTime: dateTime ?? this.dateTime,
      mood: mood ?? this.mood,
      imagePaths: imagePaths ?? this.imagePaths,
      tags: tags ?? this.tags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      weatherSummary: weatherSummary ?? this.weatherSummary,
      placeName: placeName ?? this.placeName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'dateTime': dateTime.toIso8601String(),
        'mood': mood,
        'imagePaths': imagePaths,
        'tags': tags,
        'latitude': latitude,
        'longitude': longitude,
        'weatherSummary': weatherSummary,
        'placeName': placeName,
      };

  static DiaryEntry fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        mood: json['mood'] as String? ?? 'neutral',
        imagePaths: (json['imagePaths'] as List<dynamic>? ?? const []).cast<String>(),
        tags: (json['tags'] as List<dynamic>? ?? const []).cast<String>(),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        weatherSummary: json['weatherSummary'] as String?,
        placeName: json['placeName'] as String?,
      );
}
