import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';

class WorkListScreen extends ConsumerWidget {
  const WorkListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worksAsync = ref.watch(worksStreamProvider);

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
      body: worksAsync.when(
        data: (works) {
          if (works.isEmpty) {
            return const Center(child: Text('Workがありません。作成してください'));
          }
          return ListView.builder(
            itemCount: works.length,
            itemBuilder: (context, index) {
              final work = works[index];
              final workId = work.id.toString();
              return ListTile(
                title: Text(work.name),
                onTap: () => context.pushNamed(
                  AppRoute.workDetail,
                  pathParameters: {'workId': workId},
                ),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('読み込みに失敗しました: $error')),
      ),
    );
  }
}
