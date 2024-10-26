import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bird_provider.dart';
import '../widgets/bird_info_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Birds'),
      ),
      body: Consumer<BirdProvider>(
        builder: (context, provider, child) {
          final savedBirds = provider.savedBirds;

          if (savedBirds.isEmpty) {
            return const Center(
              child: Text('No saved birds yet'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: savedBirds.length,
            itemBuilder: (context, index) {
              final bird = savedBirds[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BirdInfoCard(
                  birdInfo: bird.info,
                  audioPath: bird.audioPath,
                  canDelete: true,
                  onDelete: () => provider.deleteBirdInfo(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}