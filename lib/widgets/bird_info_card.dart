import 'package:flutter/material.dart';

class BirdInfoCard extends StatelessWidget {
  final Map<String, dynamic> birdInfo;
  final String? audioPath;
  final VoidCallback? onSave;
  final VoidCallback? onDelete;
  final bool canDelete;

  const BirdInfoCard({
    super.key,
    required this.birdInfo,
    this.audioPath,
    this.onSave,
    this.onDelete,
    this.canDelete = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (birdInfo['COMMON_NAME'] != null)
              Text(
                birdInfo['COMMON_NAME'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
            if (birdInfo['SCIENTIFIC_NAME'] != null) ...[
              const SizedBox(height: 8),
              Text(
                birdInfo['SCIENTIFIC_NAME'],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (birdInfo['FAMILY_COM_NAME'] != null) ...[
              const SizedBox(height: 8),
              Text('Family: ${birdInfo['FAMILY_COM_NAME']}'),
            ],
            if (birdInfo['ORDER'] != null) ...[
              const SizedBox(height: 4),
              Text('Order: ${birdInfo['ORDER']}'),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onSave != null)
                  TextButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                if (canDelete && onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
