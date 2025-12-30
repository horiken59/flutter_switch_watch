import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/history_detail_screen.dart';
import '../ui/screens/history_list_screen.dart';
import '../ui/screens/record_screen.dart';
import '../ui/screens/result_screen.dart';
import '../ui/screens/work_create_screen.dart';
import '../ui/screens/work_detail_screen.dart';
import '../ui/screens/work_list_screen.dart';

class AppRoute {
  static const works = 'works';
  static const workNew = 'workNew';
  static const workDetail = 'workDetail';
  static const record = 'record';
  static const sessions = 'sessions';
  static const sessionDetail = 'sessionDetail';
  static const sessionResult = 'sessionResult';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/works',
    routes: [
      GoRoute(
        path: '/works',
        name: AppRoute.works,
        builder: (context, state) => const WorkListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: AppRoute.workNew,
            builder: (context, state) => const WorkCreateScreen(),
          ),
          GoRoute(
            path: ':workId',
            name: AppRoute.workDetail,
            builder: (context, state) {
              final workId = state.pathParameters['workId'] ?? '';
              return WorkDetailScreen(workId: workId);
            },
            routes: [
              GoRoute(
                path: 'record',
                name: AppRoute.record,
                builder: (context, state) {
                  final workId = state.pathParameters['workId'] ?? '';
                  return RecordScreen(workId: workId);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/sessions',
        name: AppRoute.sessions,
        builder: (context, state) => const HistoryListScreen(),
        routes: [
          GoRoute(
            path: ':sessionId',
            name: AppRoute.sessionDetail,
            builder: (context, state) {
              final sessionId = state.pathParameters['sessionId'] ?? '';
              return HistoryDetailScreen(sessionId: sessionId);
            },
            routes: [
              GoRoute(
                path: 'result',
                name: AppRoute.sessionResult,
                builder: (context, state) {
                  final sessionId = state.pathParameters['sessionId'] ?? '';
                  return ResultScreen(sessionId: sessionId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
