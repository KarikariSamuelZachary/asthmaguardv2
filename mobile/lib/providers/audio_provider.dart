import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioProvider extends ChangeNotifier {
  AudioPlayer? player;
  bool isInitialized = false;
  bool isPlaying = false;
  String? currentSound;

  Future<void> initializeAudio() async {
    player ??= AudioPlayer();
    isInitialized = true;
    notifyListeners();
  }

  Future<void> playSound(String url, String title, String location) async {
    if (player == null) await initializeAudio();
    await player!.setUrl(url);
    await player!.play();
    isPlaying = true;
    currentSound = title;
    notifyListeners();
  }

  void setIsPlaying(bool value) {
    isPlaying = value;
    notifyListeners();
  }
}
