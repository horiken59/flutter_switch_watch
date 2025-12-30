import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';

import 'package:flutter_switch_watch/record/record_controller.dart';
import 'package:flutter_switch_watch/record/record_state.dart';

class _FakeClock {
  _FakeClock(this._current);

  DateTime _current;

  DateTime now() => _current;

  void advance(Duration duration) {
    _current = _current.add(duration);
  }
}

RecordController _buildController(
  _FakeClock clock,
  List<RecordTask> tasks,
) {
  return RecordController(
    initialState: RecordState.initial(
      workId: ObjectId(),
      workName: 'Work',
      tasks: tasks,
      now: clock.now(),
    ),
    clock: clock.now,
  );
}

void main() {
  test('Idle から Running に遷移し、開始時刻が設定される', () {
    final clock = _FakeClock(DateTime(2024, 1, 1, 0, 0, 0));
    final taskA = RecordTask(taskId: ObjectId(), name: 'A', order: 0);
    final controller = _buildController(clock, [taskA]);

    controller.onTapTask(taskA.taskId);

    final state = controller.state;
    expect(state.status, RecordStatus.running);
    expect(state.startedAt, clock.now());
    expect(state.activeTaskId, taskA.taskId);
    expect(state.totalMs, 0);
    expect(state.totalDisplayMs, 0);
  });

  test('Running 中に同じタスクをタップすると Paused になり、経過時間が加算される', () {
    final clock = _FakeClock(DateTime(2024, 1, 1, 0, 0, 0));
    final taskA = RecordTask(taskId: ObjectId(), name: 'A', order: 0);
    final controller = _buildController(clock, [taskA]);

    controller.onTapTask(taskA.taskId);
    clock.advance(const Duration(seconds: 5));

    controller.onTapTask(taskA.taskId);

    final state = controller.state;
    expect(state.status, RecordStatus.paused);
    expect(state.activeTaskId, isNull);
    expect(state.accumulatedMsByTask[taskA.taskId], 5000);
    expect(state.totalMs, 5000);
    expect(state.totalDisplayMs, 5000);
  });

  test('Running 中に別タスクをタップすると切替し、前タスクの時間を加算する', () {
    final clock = _FakeClock(DateTime(2024, 1, 1, 0, 0, 0));
    final taskA = RecordTask(taskId: ObjectId(), name: 'A', order: 0);
    final taskB = RecordTask(taskId: ObjectId(), name: 'B', order: 1);
    final controller = _buildController(clock, [taskA, taskB]);

    controller.onTapTask(taskA.taskId);
    clock.advance(const Duration(seconds: 3));
    controller.onTapTask(taskB.taskId);

    var state = controller.state;
    expect(state.status, RecordStatus.running);
    expect(state.accumulatedMsByTask[taskA.taskId], 3000);
    expect(state.activeTaskId, taskB.taskId);
    expect(state.totalMs, 3000);
    expect(state.taskDisplayMs(taskA.taskId), 3000);
    expect(state.taskDisplayMs(taskB.taskId), 0);

    clock.advance(const Duration(seconds: 2));
    controller.tick();
    state = controller.state;
    expect(state.taskDisplayMs(taskB.taskId), 2000);
    expect(state.totalDisplayMs, 5000);
    expect(
      state.totalMs,
      state.accumulatedMsByTask.values.reduce((a, b) => a + b),
    );
  });

  test('Paused からタップで Running に戻り、Pause 中は加算されない', () {
    final clock = _FakeClock(DateTime(2024, 1, 1, 0, 0, 0));
    final taskA = RecordTask(taskId: ObjectId(), name: 'A', order: 0);
    final controller = _buildController(clock, [taskA]);

    controller.onTapTask(taskA.taskId);
    clock.advance(const Duration(seconds: 4));
    controller.onTapTask(taskA.taskId); // pause

    clock.advance(const Duration(seconds: 3)); // paused time
    controller.onTapTask(taskA.taskId); // resume

    var state = controller.state;
    expect(state.status, RecordStatus.running);
    expect(state.totalMs, 4000);
    expect(state.taskDisplayMs(taskA.taskId), 4000);

    clock.advance(const Duration(seconds: 2));
    controller.tick();
    state = controller.state;
    expect(state.taskDisplayMs(taskA.taskId), 6000);
    expect(state.totalDisplayMs, 6000);
    expect(state.totalMs, 4000);
  });
}
