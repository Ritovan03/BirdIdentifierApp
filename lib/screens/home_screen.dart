import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../providers/bird_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/audio_controls.dart';
import '../widgets/bird_info_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _audioPlayer = AudioPlayer();
  final _audioRecorder = Record();
  String? _recordedPath;
  String? _selectedPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  Map<String, dynamic>? _birdInfo;
  bool _isLoading = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final tempDir = Directory.systemTemp;
        final path = '${tempDir.path}/recorded_audio.mp3';
        await _audioRecorder.start(path: path);
        setState(() {
          _isRecording = true;
          _selectedPath = null;
          _birdInfo = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording: $e')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordedPath = path;
        _selectedPath = path;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error stopping recording: $e')),
      );
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3'],
      );

      if (result != null) {
        setState(() {
          _selectedPath = result.files.single.path;
          _recordedPath = null;
          _birdInfo = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_selectedPath == null) return;

      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.play(DeviceFileSource(_selectedPath!));
        setState(() => _isPlaying = true);
      }

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() => _isPlaying = false);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  Future<void> _classifyBird() async {
    if (_selectedPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record or select an audio file first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5000/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', _selectedPath!),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final birdInfo = json.decode(responseData);

      setState(() {
        _birdInfo = birdInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error classifying bird: $e')),
      );
    }
  }

  Future<void> _saveBirdInfo() async {
    if (_birdInfo == null || _selectedPath == null) return;

    final provider = Provider.of<BirdProvider>(context, listen: false);
    await provider.saveBirdInfo(_birdInfo!, _selectedPath!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bird information saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bird Classification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AudioControls(
              isRecording: _isRecording,
              isPlaying: _isPlaying,
              hasAudio: _selectedPath != null,
              onRecord: _startRecording,
              onStopRecording: _stopRecording,
              onPickFile: _pickFile,
              onPlayPause: _togglePlayback,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _classifyBird,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Classify Bird'),
            ),
            if (_birdInfo != null) ...[
              const SizedBox(height: 16),
              BirdInfoCard(
                birdInfo: _birdInfo!,
                onSave: _saveBirdInfo,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
