import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class WorkListScreen extends StatelessWidget {
  const WorkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const dummyWorks = [
      {'id': 'work-1', 'name': 'Work 1'},
      {'id': 'work-2', 'name': 'Work 2'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.pushNamed(AppRoute.sessions),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(AppRoute.workNew),
        child: const Icon(Icons.add),
      ),
      body: dummyWorks.isEmpty
          ? const Center(child: Text('Workがありません。作成してください'))
          : ListView.builder(
              itemCount: dummyWorks.length,
              itemBuilder: (context, index) {
                final work = dummyWorks[index];
                return ListTile(
                  title: Text(work['name']!),
                  onTap: () => context.pushNamed(
                    AppRoute.workDetail,
                    pathParameters: {'workId': work['id']!},
                  ),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
    );
  }
}
