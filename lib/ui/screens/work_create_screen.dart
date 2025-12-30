import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';

class WorkCreateScreen extends StatefulWidget {
  const WorkCreateScreen({super.key});

  @override
  State<WorkCreateScreen> createState() => _WorkCreateScreenState();
}

class _WorkCreateScreenState extends State<WorkCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _taskControllers = [
    TextEditingController(text: 'Task 1'),
    TextEditingController(text: 'Task 2'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _taskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _createStubWork() {
    // Dummy creation flow: go to WorkDetail with a placeholder ID.
    context.goNamed(
      AppRoute.workDetail,
      pathParameters: {'workId': 'created-work'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Create'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Work名',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tasks (ダミー入力)'),
            ..._taskControllers.map(
              (controller) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Task名',
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _createStubWork,
                child: const Text('作成（ダミー）'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
