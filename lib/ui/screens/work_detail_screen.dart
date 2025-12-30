import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class WorkDetailScreen extends StatelessWidget {
  const WorkDetailScreen({super.key, required this.workId});

  final String workId;

  @override
  Widget build(BuildContext context) {
    const tasks = ['Task 1', 'Task 2', 'Task 3'];
    return Scaffold(
      appBar: AppBar(title: const Text('Work Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work ID: $workId'),
            const SizedBox(height: 16),
            const Text('Tasks'),
            const SizedBox(height: 8),
            ...tasks.map((task) => ListTile(title: Text(task))),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pushNamed(
                  AppRoute.record,
                  pathParameters: {'workId': workId},
                ),
                child: const Text('記録する'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
