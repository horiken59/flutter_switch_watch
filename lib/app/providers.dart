import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/realm/realm_config.dart';
import '../data/work_repository.dart';
import '../models/work.dart';

final workRepositoryProvider = Provider<WorkRepository>((ref) {
  final realm = ref.watch(realmProvider);
  return WorkRepository(realm);
});

final worksStreamProvider = StreamProvider<List<Work>>((ref) {
  final repository = ref.watch(workRepositoryProvider);
  return repository.watchWorks();
});
