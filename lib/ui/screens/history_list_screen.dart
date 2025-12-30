import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class HistoryListScreen extends StatelessWidget {
  const HistoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const dummySessions = [
      {'id': 'session-1', 'workName': 'Work 1', 'total': '00:10:00'},
      {'id': 'session-2', 'workName': 'Work 2', 'total': '00:05:00'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('History List')),
      body: dummySessions.isEmpty
          ? const Center(child: Text('履歴がありません'))
          : ListView.builder(
              itemCount: dummySessions.length,
              itemBuilder: (context, index) {
                final session = dummySessions[index];
                return ListTile(
                  title: Text(session['workName']!),
                  subtitle: Text('合計: ${session['total']}'),
                  onTap: () => context.pushNamed(
                    AppRoute.sessionDetail,
                    pathParameters: {'sessionId': session['id']!},
                  ),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
    );
  }
}
