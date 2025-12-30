import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/router.dart';

class WorkCreateScreen extends ConsumerStatefulWidget {
  const WorkCreateScreen({super.key});

  @override
  ConsumerState<WorkCreateScreen> createState() => _WorkCreateScreenState();
}

class _WorkCreateScreenState extends ConsumerState<WorkCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _taskControllers = [
    TextEditingController(),
  ];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _taskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addTaskField() {
    setState(() {
      _taskControllers.add(TextEditingController());
    });
  }

  void _removeTaskField(int index) {
    if (_taskControllers.length <= 1) return;
    setState(() {
      _taskControllers.removeAt(index).dispose();
    });
  }

  Future<void> _createWork() async {
    setState(() => _isSaving = true);
    try {
      final repository = ref.read(workRepositoryProvider);
      final workId = await repository.createWork(
        name: _nameController.text,
        taskNames: _taskControllers.map((c) => c.text).toList(),
      );
      if (!mounted) return;
      context.goNamed(
        AppRoute.workDetail,
        pathParameters: {'workId': workId.toString()},
      );
    } on ArgumentError catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? e.toString())));
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('作成に失敗しました')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Work Create')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Work名'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tasks'),
                TextButton.icon(
                  onPressed: _addTaskField,
                  icon: const Icon(Icons.add),
                  label: const Text('追加'),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _taskControllers.length,
                itemBuilder: (context, index) {
                  final controller = _taskControllers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText: 'Task名 ${index + 1}',
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeTaskField(index),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSaving ? null : _createWork,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('作成'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
