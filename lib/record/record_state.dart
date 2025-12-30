import 'package:realm/realm.dart';

enum RecordStatus {
  idle,
  running,
  paused,
}

class RecordTask {
  const RecordTask({
    required this.taskId,
    required this.name,
    required this.order,
  });

  final ObjectId taskId;
  final String name;
  final int order;
}

class RecordState {
  RecordState({
    required this.workId,
    required this.workName,
    required List<RecordTask> tasks,
    required Map<ObjectId, int> accumulatedMsByTask,
    required this.displayNowMs,
    this.startedAt,
    this.activeTaskId,
    this.activeTaskStartedAt,
    this.lastActiveTaskId,
  })  : tasks = List.unmodifiable(
          List<RecordTask>.from(tasks)
            ..sort((a, b) => a.order.compareTo(b.order)),
        ),
        accumulatedMsByTask =
            Map<ObjectId, int>.unmodifiable(Map.of(accumulatedMsByTask));

  factory RecordState.initial({
    required ObjectId workId,
    required String workName,
    required List<RecordTask> tasks,
    required DateTime now,
  }) {
    final sortedTasks = List<RecordTask>.from(tasks)
      ..sort((a, b) => a.order.compareTo(b.order));
    final accumulated = {
      for (final task in sortedTasks) task.taskId: 0,
    };
    return RecordState(
      workId: workId,
      workName: workName,
      tasks: sortedTasks,
      accumulatedMsByTask: accumulated,
      displayNowMs: now.millisecondsSinceEpoch,
    );
  }

  final ObjectId workId;
  final String workName;
  final List<RecordTask> tasks;
  final Map<ObjectId, int> accumulatedMsByTask;
  final int displayNowMs;
  final DateTime? startedAt;
  final ObjectId? activeTaskId;
  final DateTime? activeTaskStartedAt;
  final ObjectId? lastActiveTaskId;

  RecordStatus get status {
    if (startedAt == null) {
      return RecordStatus.idle;
    }
    if (activeTaskId == null) {
      return RecordStatus.paused;
    }
    return RecordStatus.running;
  }

  bool get hasStartedOnce => startedAt != null;

  int get totalMs =>
      accumulatedMsByTask.values.fold<int>(0, (sum, v) => sum + v);

  int get _activeElapsedMs {
    if (status != RecordStatus.running || activeTaskStartedAt == null) {
      return 0;
    }
    final elapsed =
        displayNowMs - activeTaskStartedAt!.millisecondsSinceEpoch;
    return elapsed < 0 ? 0 : elapsed;
  }

  int get totalDisplayMs => totalMs + _activeElapsedMs;

  int taskDisplayMs(ObjectId taskId) {
    final base = accumulatedMsByTask[taskId] ?? 0;
    if (taskId != activeTaskId) {
      return base;
    }
    return base + _activeElapsedMs;
  }

  static const _unset = Object();

  RecordState copyWith({
    ObjectId? workId,
    String? workName,
    List<RecordTask>? tasks,
    Map<ObjectId, int>? accumulatedMsByTask,
    int? displayNowMs,
    DateTime? startedAt,
    Object? activeTaskId = _unset,
    Object? activeTaskStartedAt = _unset,
    Object? lastActiveTaskId = _unset,
  }) {
    return RecordState(
      workId: workId ?? this.workId,
      workName: workName ?? this.workName,
      tasks: tasks ?? this.tasks,
      accumulatedMsByTask:
          accumulatedMsByTask ?? this.accumulatedMsByTask,
      displayNowMs: displayNowMs ?? this.displayNowMs,
      startedAt: startedAt ?? this.startedAt,
      activeTaskId: activeTaskId == _unset
          ? this.activeTaskId
          : activeTaskId as ObjectId?,
      activeTaskStartedAt: activeTaskStartedAt == _unset
          ? this.activeTaskStartedAt
          : activeTaskStartedAt as DateTime?,
      lastActiveTaskId: lastActiveTaskId == _unset
          ? this.lastActiveTaskId
          : lastActiveTaskId as ObjectId?,
    );
  }

  RecordState reset(DateTime now) {
    return RecordState.initial(
      workId: workId,
      workName: workName,
      tasks: tasks,
      now: now,
    );
  }
}
