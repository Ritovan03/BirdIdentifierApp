import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class BirdInfoCard extends StatefulWidget {
  final Map<String, dynamic> birdInfo;
  final String? audioPath;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final bool canDelete;

  const BirdInfoCard({
    Key? key,
    required this.birdInfo,
    this.audioPath,
    this.onSave,
    this.onDelete,
    this.canDelete = false,
  }) : super(key: key);

  @override
  State<BirdInfoCard> createState() => _BirdInfoCardState();
}

class _BirdInfoCardState extends State<BirdInfoCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
        setState(() => _isPlaying = false);
      } else {
        await _audioPlayer.play(DeviceFileSource(widget.audioPath!));
        setState(() => _isPlaying = true);

        // Listen for playback completion
        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() => _isPlaying = false);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.birdInfo['PRIMARY_COM_NAME']?.toString() ?? 'Unknown Bird',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (widget.birdInfo['SCI_NAME'] != null)
                        Text(
                          widget.birdInfo['SCI_NAME'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.canDelete)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onDelete,
                  ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Order:', widget.birdInfo['ORDER1']?.toString() ?? 'N/A'),
            _buildInfoRow('Family:', widget.birdInfo['FAMILY']?.toString() ?? 'N/A'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.audioPath != null)
                  ElevatedButton.icon(
                    onPressed: _togglePlayback,
                    icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(_isPlaying ? 'Stop' : 'Play Recording'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                if (widget.onSave != null)
                  ElevatedButton.icon(
                    onPressed: widget.onSave,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}