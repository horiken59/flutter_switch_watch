// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Work extends _Work with RealmEntity, RealmObjectBase, RealmObject {
  Work(
    ObjectId id,
    String name,
    DateTime createdAt,
    DateTime updatedAt, {
    Iterable<TaskDef> tasks = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set<RealmList<TaskDef>>(
      this,
      'tasks',
      RealmList<TaskDef>(tasks),
    );
    RealmObjectBase.set(this, 'createdAt', createdAt);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  Work._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  RealmList<TaskDef> get tasks =>
      RealmObjectBase.get<TaskDef>(this, 'tasks') as RealmList<TaskDef>;
  @override
  set tasks(covariant RealmList<TaskDef> value) =>
      throw RealmUnsupportedSetError();

  @override
  DateTime get createdAt =>
      RealmObjectBase.get<DateTime>(this, 'createdAt') as DateTime;
  @override
  set createdAt(DateTime value) =>
      RealmObjectBase.set(this, 'createdAt', value);

  @override
  DateTime get updatedAt =>
      RealmObjectBase.get<DateTime>(this, 'updatedAt') as DateTime;
  @override
  set updatedAt(DateTime value) =>
      RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<Work>> get changes =>
      RealmObjectBase.getChanges<Work>(this);

  @override
  Stream<RealmObjectChanges<Work>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Work>(this, keyPaths);

  @override
  Work freeze() => RealmObjectBase.freezeObject<Work>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'name': name.toEJson(),
      'tasks': tasks.toEJson(),
      'createdAt': createdAt.toEJson(),
      'updatedAt': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Work value) => value.toEJson();
  static Work _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'name': EJsonValue name,
        'createdAt': EJsonValue createdAt,
        'updatedAt': EJsonValue updatedAt,
      } =>
        Work(
          fromEJson(id),
          fromEJson(name),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          tasks: fromEJson(ejson['tasks']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Work._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Work, 'Work', [
      SchemaProperty(
        'id',
        RealmPropertyType.objectid,
        mapTo: '_id',
        primaryKey: true,
      ),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty(
        'tasks',
        RealmPropertyType.object,
        linkTarget: 'TaskDef',
        collectionType: RealmCollectionType.list,
      ),
      SchemaProperty('createdAt', RealmPropertyType.timestamp),
      SchemaProperty('updatedAt', RealmPropertyType.timestamp),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class TaskDef extends _TaskDef
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  TaskDef(ObjectId taskId, String name, int order) {
    RealmObjectBase.set(this, 'taskId', taskId);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'order', order);
  }

  TaskDef._();

  @override
  ObjectId get taskId =>
      RealmObjectBase.get<ObjectId>(this, 'taskId') as ObjectId;
  @override
  set taskId(ObjectId value) => RealmObjectBase.set(this, 'taskId', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int get order => RealmObjectBase.get<int>(this, 'order') as int;
  @override
  set order(int value) => RealmObjectBase.set(this, 'order', value);

  @override
  Stream<RealmObjectChanges<TaskDef>> get changes =>
      RealmObjectBase.getChanges<TaskDef>(this);

  @override
  Stream<RealmObjectChanges<TaskDef>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<TaskDef>(this, keyPaths);

  @override
  TaskDef freeze() => RealmObjectBase.freezeObject<TaskDef>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'taskId': taskId.toEJson(),
      'name': name.toEJson(),
      'order': order.toEJson(),
    };
  }

  static EJsonValue _toEJson(TaskDef value) => value.toEJson();
  static TaskDef _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'taskId': EJsonValue taskId,
        'name': EJsonValue name,
        'order': EJsonValue order,
      } =>
        TaskDef(fromEJson(taskId), fromEJson(name), fromEJson(order)),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TaskDef._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.embeddedObject, TaskDef, 'TaskDef', [
      SchemaProperty('taskId', RealmPropertyType.objectid),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('order', RealmPropertyType.int),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
