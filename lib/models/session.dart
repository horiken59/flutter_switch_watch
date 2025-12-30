import 'package:realm/realm.dart';

part 'session.realm.dart';

@RealmModel()
class _Session {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late ObjectId workId;
  late String workNameSnapshot;
  late DateTime startedAt;
  late DateTime endedAt;
  late int totalMs;
  late List<_SessionTaskTotal> taskTotals;
}

@RealmModel(ObjectType.embeddedObject)
class _SessionTaskTotal {
  @MapTo('taskId')
  late ObjectId taskId;

  late String taskNameSnapshot;
  late int durationMs;
  late int order;
}
