import 'package:realm/realm.dart';

import '../models/work.dart';

class WorkRepository {
  WorkRepository(this._realm);

  final Realm _realm;

  Future<ObjectId> createWork({
    required String name,
    required List<String> taskNames,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Work名は必須です');
    }

    final trimmedTasks = taskNames
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (trimmedTasks.isEmpty) {
      throw ArgumentError('Taskは1件以上必要です');
    }

    final seen = <String>{};
    for (final taskName in trimmedTasks) {
      if (!seen.add(taskName)) {
        throw ArgumentError('Task名が重複しています');
      }
    }

    final now = DateTime.now();
    final tasks = trimmedTasks.asMap().entries.map(
      (entry) => TaskDef(ObjectId(), entry.value, entry.key),
    );

    final workId = _realm.write<ObjectId>(() {
      final work = Work(ObjectId(), trimmedName, now, now, tasks: tasks);
      _realm.add(work);
      return work.id;
    });

    return workId;
  }

  Stream<List<Work>> watchWorks() {
    return _realm.all<Work>().changes.map((changes) {
      return changes.results.toList();
    });
  }
}
