// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Session extends _Session with RealmEntity, RealmObjectBase, RealmObject {
  Session(
    ObjectId id,
    ObjectId workId,
    String workNameSnapshot,
    DateTime startedAt,
    DateTime endedAt,
    int totalMs, {
    Iterable<SessionTaskTotal> taskTotals = const [],
  }) {
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'workId', workId);
    RealmObjectBase.set(this, 'workNameSnapshot', workNameSnapshot);
    RealmObjectBase.set(this, 'startedAt', startedAt);
    RealmObjectBase.set(this, 'endedAt', endedAt);
    RealmObjectBase.set(this, 'totalMs', totalMs);
    RealmObjectBase.set<RealmList<SessionTaskTotal>>(
      this,
      'taskTotals',
      RealmList<SessionTaskTotal>(taskTotals),
    );
  }

  Session._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  ObjectId get workId =>
      RealmObjectBase.get<ObjectId>(this, 'workId') as ObjectId;
  @override
  set workId(ObjectId value) => RealmObjectBase.set(this, 'workId', value);

  @override
  String get workNameSnapshot =>
      RealmObjectBase.get<String>(this, 'workNameSnapshot') as String;
  @override
  set workNameSnapshot(String value) =>
      RealmObjectBase.set(this, 'workNameSnapshot', value);

  @override
  DateTime get startedAt =>
      RealmObjectBase.get<DateTime>(this, 'startedAt') as DateTime;
  @override
  set startedAt(DateTime value) =>
      RealmObjectBase.set(this, 'startedAt', value);

  @override
  DateTime get endedAt =>
      RealmObjectBase.get<DateTime>(this, 'endedAt') as DateTime;
  @override
  set endedAt(DateTime value) => RealmObjectBase.set(this, 'endedAt', value);

  @override
  int get totalMs => RealmObjectBase.get<int>(this, 'totalMs') as int;
  @override
  set totalMs(int value) => RealmObjectBase.set(this, 'totalMs', value);

  @override
  RealmList<SessionTaskTotal> get taskTotals =>
      RealmObjectBase.get<SessionTaskTotal>(this, 'taskTotals')
          as RealmList<SessionTaskTotal>;
  @override
  set taskTotals(covariant RealmList<SessionTaskTotal> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Session>> get changes =>
      RealmObjectBase.getChanges<Session>(this);

  @override
  Stream<RealmObjectChanges<Session>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Session>(this, keyPaths);

  @override
  Session freeze() => RealmObjectBase.freezeObject<Session>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      '_id': id.toEJson(),
      'workId': workId.toEJson(),
      'workNameSnapshot': workNameSnapshot.toEJson(),
      'startedAt': startedAt.toEJson(),
      'endedAt': endedAt.toEJson(),
      'totalMs': totalMs.toEJson(),
      'taskTotals': taskTotals.toEJson(),
    };
  }

  static EJsonValue _toEJson(Session value) => value.toEJson();
  static Session _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        '_id': EJsonValue id,
        'workId': EJsonValue workId,
        'workNameSnapshot': EJsonValue workNameSnapshot,
        'startedAt': EJsonValue startedAt,
        'endedAt': EJsonValue endedAt,
        'totalMs': EJsonValue totalMs,
      } =>
        Session(
          fromEJson(id),
          fromEJson(workId),
          fromEJson(workNameSnapshot),
          fromEJson(startedAt),
          fromEJson(endedAt),
          fromEJson(totalMs),
          taskTotals: fromEJson(ejson['taskTotals']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Session._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Session, 'Session', [
      SchemaProperty(
        'id',
        RealmPropertyType.objectid,
        mapTo: '_id',
        primaryKey: true,
      ),
      SchemaProperty('workId', RealmPropertyType.objectid),
      SchemaProperty('workNameSnapshot', RealmPropertyType.string),
      SchemaProperty('startedAt', RealmPropertyType.timestamp),
      SchemaProperty('endedAt', RealmPropertyType.timestamp),
      SchemaProperty('totalMs', RealmPropertyType.int),
      SchemaProperty(
        'taskTotals',
        RealmPropertyType.object,
        linkTarget: 'SessionTaskTotal',
        collectionType: RealmCollectionType.list,
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class SessionTaskTotal extends _SessionTaskTotal
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  SessionTaskTotal(
    ObjectId taskId,
    String taskNameSnapshot,
    int durationMs,
    int order,
  ) {
    RealmObjectBase.set(this, 'taskId', taskId);
    RealmObjectBase.set(this, 'taskNameSnapshot', taskNameSnapshot);
    RealmObjectBase.set(this, 'durationMs', durationMs);
    RealmObjectBase.set(this, 'order', order);
  }

  SessionTaskTotal._();

  @override
  ObjectId get taskId =>
      RealmObjectBase.get<ObjectId>(this, 'taskId') as ObjectId;
  @override
  set taskId(ObjectId value) => RealmObjectBase.set(this, 'taskId', value);

  @override
  String get taskNameSnapshot =>
      RealmObjectBase.get<String>(this, 'taskNameSnapshot') as String;
  @override
  set taskNameSnapshot(String value) =>
      RealmObjectBase.set(this, 'taskNameSnapshot', value);

  @override
  int get durationMs => RealmObjectBase.get<int>(this, 'durationMs') as int;
  @override
  set durationMs(int value) => RealmObjectBase.set(this, 'durationMs', value);

  @override
  int get order => RealmObjectBase.get<int>(this, 'order') as int;
  @override
  set order(int value) => RealmObjectBase.set(this, 'order', value);

  @override
  Stream<RealmObjectChanges<SessionTaskTotal>> get changes =>
      RealmObjectBase.getChanges<SessionTaskTotal>(this);

  @override
  Stream<RealmObjectChanges<SessionTaskTotal>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SessionTaskTotal>(this, keyPaths);

  @override
  SessionTaskTotal freeze() =>
      RealmObjectBase.freezeObject<SessionTaskTotal>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'taskId': taskId.toEJson(),
      'taskNameSnapshot': taskNameSnapshot.toEJson(),
      'durationMs': durationMs.toEJson(),
      'order': order.toEJson(),
    };
  }

  static EJsonValue _toEJson(SessionTaskTotal value) => value.toEJson();
  static SessionTaskTotal _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'taskId': EJsonValue taskId,
        'taskNameSnapshot': EJsonValue taskNameSnapshot,
        'durationMs': EJsonValue durationMs,
        'order': EJsonValue order,
      } =>
        SessionTaskTotal(
          fromEJson(taskId),
          fromEJson(taskNameSnapshot),
          fromEJson(durationMs),
          fromEJson(order),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SessionTaskTotal._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.embeddedObject,
      SessionTaskTotal,
      'SessionTaskTotal',
      [
        SchemaProperty('taskId', RealmPropertyType.objectid),
        SchemaProperty('taskNameSnapshot', RealmPropertyType.string),
        SchemaProperty('durationMs', RealmPropertyType.int),
        SchemaProperty('order', RealmPropertyType.int),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
