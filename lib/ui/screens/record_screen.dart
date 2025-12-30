import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

import '../../app/providers.dart';
import '../../models/work.dart';
import '../../record/record_controller.dart';
import '../../record/record_state.dart';
import '../../record/time_formatter.dart';

class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({super.key, required this.workId});

  final String workId;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  ObjectId? _workObjectId;
  bool _parseError = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _parseWorkId();
  }

  void _parseWorkId() {
    try {
      _workObjectId = ObjectId.fromHexString(widget.workId);
    } catch (_) {
      _parseError = true;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker(RecordController controller) {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      controller.tick();
    });
  }

  Future<bool> _handlePop(
    RecordController controller,
    RecordState state,
  ) async {
    if (!state.hasStartedOnce) {
      return true;
    }
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('記録を破棄しますか？'),
          content: const Text('この記録は保存されません。戻りますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('破棄して戻る'),
            ),
          ],
        );
      },
    );
    if (shouldDiscard == true) {
      controller.reset();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_parseError || _workObjectId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Record')),
        body: const Center(child: Text('Work ID が不正です')),
      );
    }

    final worksAsync = ref.watch(worksStreamProvider);
    return worksAsync.when(
      data: (works) {
        Work? work;
        for (final w in works) {
          if (w.id == _workObjectId) {
            work = w;
            break;
          }
        }
        if (work == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Record')),
            body: const Center(child: Text('Work が見つかりません')),
          );
        }

        final tasks = work.tasks
            .map(
              (t) => RecordTask(
                taskId: t.taskId,
                name: t.name,
                order: t.order,
              ),
            )
            .toList();

        final args = RecordControllerArgs(
          workId: work.id,
          workName: work.name,
          tasks: tasks,
        );
        final state = ref.watch(recordControllerProvider(args));
        final controller = ref.read(recordControllerProvider(args).notifier);
        _startTicker(controller);

        return WillPopScope(
          onWillPop: () => _handlePop(controller, state),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Record'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  final allowPop = await _handlePop(controller, state);
                  if (allowPop && mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
            body: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.grey.shade200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          work.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(formatDuration(state.totalDisplayMs)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.tasks.length,
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      final isActive = state.activeTaskId == task.taskId;
                      return ListTile(
                        title: Text(task.name),
                        trailing: Text(
                          formatDuration(state.taskDisplayMs(task.taskId)),
                        ),
                        tileColor:
                            isActive ? Colors.lightBlue.shade50 : Colors.white,
                        onTap: () {
                          controller.onTapTask(task.taskId);
                        },
                      );
                    },
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: null,
                        child: const Text('Finish（次のスライスで実装）'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Record')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: const Text('Record')),
        body: Center(child: Text('読み込みに失敗しました: $error')),
      ),
    );
  }
}
