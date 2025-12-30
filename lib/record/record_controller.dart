import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

import 'record_state.dart';

class RecordController extends StateNotifier<RecordState> {
  RecordController({
    required RecordState initialState,
    DateTime Function()? clock,
  })  : _clock = clock ?? DateTime.now,
        super(initialState);

  final DateTime Function() _clock;

  void onTapTask(ObjectId taskId) {
    final now = _clock();
    final status = state.status;
    switch (status) {
      case RecordStatus.idle:
        _start(taskId, now);
        break;
      case RecordStatus.running:
        if (state.activeTaskId == taskId) {
          _pause(now);
        } else {
          _switch(taskId, now);
        }
        break;
      case RecordStatus.paused:
        _resume(taskId, now);
        break;
    }
  }

  void tick([DateTime? now]) {
    final current = now ?? _clock();
    state = state.copyWith(displayNowMs: current.millisecondsSinceEpoch);
  }

  void reset() {
    final now = _clock();
    state = state.reset(now);
  }

  Map<ObjectId, int> _addElapsedToActive(
    Map<ObjectId, int> source,
    ObjectId activeId,
    int elapsedMs,
  ) {
    final updated = Map<ObjectId, int>.from(source);
    final current = updated[activeId] ?? 0;
    updated[activeId] = current + elapsedMs;
    return updated;
  }

  int _elapsedMs(DateTime? from, DateTime now) {
    if (from == null) {
      return 0;
    }
    final elapsed = now.millisecondsSinceEpoch - from.millisecondsSinceEpoch;
    return elapsed < 0 ? 0 : elapsed;
  }

  void _start(ObjectId taskId, DateTime now) {
    state = state.copyWith(
      startedAt: now,
      activeTaskId: taskId,
      activeTaskStartedAt: now,
      lastActiveTaskId: taskId,
      displayNowMs: now.millisecondsSinceEpoch,
    );
  }

  void _pause(DateTime now) {
    final activeId = state.activeTaskId;
    if (activeId == null) {
      return;
    }
    final elapsed = _elapsedMs(state.activeTaskStartedAt, now);
    final accumulated =
        _addElapsedToActive(state.accumulatedMsByTask, activeId, elapsed);
    state = state.copyWith(
      accumulatedMsByTask: accumulated,
      activeTaskId: null,
      activeTaskStartedAt: null,
      lastActiveTaskId: activeId,
      displayNowMs: now.millisecondsSinceEpoch,
    );
  }

  void _switch(ObjectId nextTaskId, DateTime now) {
    final activeId = state.activeTaskId;
    if (activeId == null) {
      return;
    }
    final elapsed = _elapsedMs(state.activeTaskStartedAt, now);
    final accumulated =
        _addElapsedToActive(state.accumulatedMsByTask, activeId, elapsed);
    state = state.copyWith(
      accumulatedMsByTask: accumulated,
      activeTaskId: nextTaskId,
      activeTaskStartedAt: now,
      lastActiveTaskId: nextTaskId,
      displayNowMs: now.millisecondsSinceEpoch,
    );
  }

  void _resume(ObjectId taskId, DateTime now) {
    state = state.copyWith(
      activeTaskId: taskId,
      activeTaskStartedAt: now,
      lastActiveTaskId: taskId,
      displayNowMs: now.millisecondsSinceEpoch,
    );
  }
}

class RecordControllerArgs {
  const RecordControllerArgs({
    required this.workId,
    required this.workName,
    required this.tasks,
  });

  final ObjectId workId;
  final String workName;
  final List<RecordTask> tasks;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordControllerArgs &&
        other.workId == workId &&
        other.workName == workName &&
        _listEquals(other.tasks, tasks);
  }

  @override
  int get hashCode => Object.hash(
        workId,
        workName,
        Object.hashAll(tasks.map((t) => Object.hash(t.taskId, t.name, t.order))),
      );

  bool _listEquals(List<RecordTask> a, List<RecordTask> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      final left = a[i];
      final right = b[i];
      if (left.taskId != right.taskId ||
          left.name != right.name ||
          left.order != right.order) {
        return false;
      }
    }
    return true;
  }
}

final recordControllerProvider = StateNotifierProvider.autoDispose
    .family<RecordController, RecordState, RecordControllerArgs>(
  (ref, args) {
    final now = DateTime.now();
    final initialState = RecordState.initial(
      workId: args.workId,
      workName: args.workName,
      tasks: args.tasks,
      now: now,
    );
    return RecordController(initialState: initialState);
  },
);
