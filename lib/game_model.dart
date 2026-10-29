class GameEntry {
  const GameEntry({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    required this.rating,
  });

  final String id;
  final String title;
  final String status;
  final int progress;
  final double rating;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'progress': progress,
      'rating': rating,
    };
  }

  factory GameEntry.fromJson(Map<String, dynamic> json) {
    return GameEntry(
      id: json['id'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
    );
  }
}
