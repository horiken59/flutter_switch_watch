import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';

import '../../models/session.dart';
import '../../models/work.dart';

const _schemas = [
  Work.schema,
  TaskDef.schema,
  Session.schema,
  SessionTaskTotal.schema,
];

final realmProvider = Provider<Realm>((ref) {
  final config = Configuration.local(_schemas, schemaVersion: 1);
  final realm = Realm(config);
  ref.onDispose(realm.close);
  return realm;
});
