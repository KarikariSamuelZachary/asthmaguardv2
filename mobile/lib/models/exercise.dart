class Exercise {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final int duration; // in seconds
  final int calories;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.duration,
    required this.calories,
  });
}
