import 'package:flutter/material.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session ID: $sessionId'),
            const SizedBox(height: 12),
            const Text('Work名: Work Snapshot'),
            const Text('Started: --'),
            const Text('Ended: --'),
            const SizedBox(height: 12),
            const Text('合計時間: 00:00:00'),
            const SizedBox(height: 12),
            const Text('タスク内訳'),
            const ListTile(
              title: Text('Task 1'),
              trailing: Text('00:00:00'),
            ),
          ],
        ),
      ),
    );
  }
}
