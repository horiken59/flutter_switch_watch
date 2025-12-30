import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key, required this.workId});

  final String workId;

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _hasStarted = false;
  String? _activeTask;

  Future<bool> _handlePop() async {
    if (!_hasStarted) {
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
      setState(() {
        _hasStarted = false;
        _activeTask = null;
      });
      return true;
    }
    return false;
  }

  void _onTapTask(String taskName) {
    setState(() {
      _hasStarted = true;
      _activeTask = taskName;
    });
  }

  void _onFinish() {
    context.goNamed(
      AppRoute.sessionResult,
      pathParameters: {'sessionId': 'session-stub'},
    );
  }

  @override
  Widget build(BuildContext context) {
    const tasks = ['Task 1', 'Task 2', 'Task 3'];
    return WillPopScope(
      onWillPop: _handlePop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Record'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final allowPop = await _handlePop();
              if (allowPop && mounted) {
                context.pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Work ID: ${widget.workId}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Text('00:00:00'),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final isActive = _activeTask == task;
                  return ListTile(
                    title: Text(task),
                    trailing: const Text('00:00:00'),
                    tileColor: isActive
                        ? Colors.lightBlue.shade50
                        : Colors.white,
                    onTap: () => _onTapTask(task),
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
                    onPressed: _onFinish,
                    child: const Text('Finish（ダミー）'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
