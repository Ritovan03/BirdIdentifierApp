import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class AudioControls extends StatelessWidget {
  final bool isRecording;
  final bool isPlaying;
  final bool hasAudio;
  final VoidCallback onRecord;
  final VoidCallback onStopRecording;
  final VoidCallback onPickFile;
  final VoidCallback onPlayPause;

  const AudioControls({
    super.key,
    required this.isRecording,
    required this.isPlaying,
    required this.hasAudio,
    required this.onRecord,
    required this.onStopRecording,
    required this.onPickFile,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: isRecording ? onStopRecording : onRecord,
                  icon: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: isRecording ? Colors.red : null,
                  ),
                ),
                IconButton(
                  onPressed: onPickFile,
                  icon: const Icon(Icons.file_upload),
                ),
                if (hasAudio)
                  IconButton(
                    onPressed: onPlayPause,
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isRecording ? 'Recording...' : 'Ready to record or upload',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class SavedBird {
  final Map<String, dynamic> info;
  final String audioPath;

  SavedBird({required this.info, required this.audioPath});

  Map<String, dynamic> toJson() => {
    'info': info,
    'audioPath': audioPath,
  };

  factory SavedBird.fromJson(Map<String, dynamic> json) => SavedBird(
    info: json['info'],
    audioPath: json['audioPath'],
  );
}

class BirdProvider with ChangeNotifier {
  List<SavedBird> _savedBirds = [];
  List<SavedBird> get savedBirds => _savedBirds;

  BirdProvider() {
    _loadSavedBirds();
  }

  Future<void> _loadSavedBirds() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/saved_birds.json');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        _savedBirds = jsonList.map((e) => SavedBird.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved birds: $e');
    }
  }

  Future<void> _saveBirdsToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/saved_birds.json');
      final jsonList = _savedBirds.map((bird) => bird.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      debugPrint('Error saving birds: $e');
    }
  }

  Future<void> saveBirdInfo(Map<String, dynamic> birdInfo, String audioPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'bird_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      final savedAudioPath = '${directory.path}/audio/$fileName';

      // Create audio directory if it doesn't exist
      final audioDirectory = Directory('${directory.path}/audio');
      if (!await audioDirectory.exists()) {
        await audioDirectory.create(recursive: true);
      }

      // Copy audio file to app directory
      await File(audioPath).copy(savedAudioPath);

      _savedBirds.add(SavedBird(
        info: birdInfo,
        audioPath: savedAudioPath,
      ));

      await _saveBirdsToFile();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving bird info: $e');
      rethrow;
    }
  }

  Future<void> deleteBirdInfo(int index) async {
    try {
      final bird = _savedBirds[index];
      final audioFile = File(bird.audioPath);

      if (await audioFile.exists()) {
        await audioFile.delete();
      }

      _savedBirds.removeAt(index);
      await _saveBirdsToFile();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting bird info: $e');
      rethrow;
    }
  }
}