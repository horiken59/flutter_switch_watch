import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session ID: $sessionId'),
            const SizedBox(height: 12),
            const Text('Work名: Work Snapshot'),
            const SizedBox(height: 8),
            const Text('合計時間: 00:00:00'),
            const SizedBox(height: 16),
            const Text('タスク内訳'),
            const ListTile(title: Text('Task 1'), trailing: Text('00:00:00')),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.goNamed(
                      AppRoute.sessionDetail,
                      pathParameters: {'sessionId': sessionId},
                    ),
                    child: const Text('履歴詳細へ'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => context.goNamed(AppRoute.sessions),
                    child: const Text('履歴一覧へ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
