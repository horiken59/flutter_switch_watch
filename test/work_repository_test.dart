import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';

import 'package:flutter_switch_watch/data/work_repository.dart';
import 'package:flutter_switch_watch/models/work.dart';

void main() {
  late Realm realm;
  late WorkRepository repository;

  setUp(() {
    final config = Configuration.inMemory([
      Work.schema,
      TaskDef.schema,
    ]);
    realm = Realm(config);
    repository = WorkRepository(realm);
  });

  tearDown(() {
    realm.close();
  });

  test('create and list work', () async {
    final workId = await repository.createWork(
      name: 'Cooking',
      taskNames: ['Cut', 'Boil'],
    );

    final works = await repository.watchWorks().first;

    expect(works, hasLength(1));
    final work = works.first;
    expect(work.id.toString(), workId.toString());
    expect(work.name, 'Cooking');
    expect(work.tasks.length, 2);
    expect(work.tasks[0].name, 'Cut');
    expect(work.tasks[0].order, 0);
    expect(work.tasks[1].order, 1);
  });
}
