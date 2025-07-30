import 'package:flutter/material.dart';
import '../models/sound.dart';

class SoundProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _sounds = [];
  String _category = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasMore = false;

  List<Map<String, dynamic>> get sounds => _sounds;
  String get category => _category;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  void setCategory(String category) {
    _category = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> searchSounds({bool refresh = false}) async {
    _isLoading = true;
    notifyListeners();
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));
    // Dummy data
    _sounds = [
      {
        'id': '1',
        'name': 'Rainforest',
        'username': 'Nature',
        'category': 'nature',
        'previews': {'preview-hq-mp3': ''},
        'images': {'waveform_m': ''},
        'duration': 120.0,
      },
      {
        'id': '2',
        'name': 'Ocean Waves',
        'username': 'Nature',
        'category': 'nature',
        'previews': {'preview-hq-mp3': ''},
        'images': {'waveform_m': ''},
        'duration': 180.0,
      },
    ];
    _hasMore = false;
    _isLoading = false;
    notifyListeners();
  }
}
