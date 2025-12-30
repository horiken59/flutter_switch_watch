import 'package:realm/realm.dart';

part 'work.realm.dart';

@RealmModel()
class _Work {
  @PrimaryKey()
  @MapTo('_id')
  late ObjectId id;

  late String name;
  late List<_TaskDef> tasks;
  late DateTime createdAt;
  late DateTime updatedAt;
}

@RealmModel(ObjectType.embeddedObject)
class _TaskDef {
  @MapTo('taskId')
  late ObjectId taskId;

  late String name;
  late int order;
}
