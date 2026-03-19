enum SoundCategory { all, nature, ambient, meditation, binaural }

class Sound {
  final String id;
  final String title;
  final String location;
  final String category;
  final String audioURL;
  final String imageName;
  final double? duration;

  Sound({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.audioURL,
    required this.imageName,
    this.duration,
  });
}
