import 'package:go_router/go_router.dart';

import '../screens/contents_screen.dart';
import '../screens/courses_screen.dart';
import '../screens/levels_screen.dart';
import '../screens/result_screen.dart';
import '../screens/test_screen.dart';
import '../screens/welcome_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
          path: '/levels',
          builder: (context, state) => const LevelsScreen()),
      GoRoute(
          path: '/courses',
          builder: (context, state) => const CoursesScreen()),
      GoRoute(
          path: '/contents',
          builder: (context, state) => const ContentsScreen()),
      GoRoute(
          path: '/test', builder: (context, state) => const TestScreen()),
      GoRoute(
          path: '/result',
          builder: (context, state) => const ResultScreen()),
    ],
  );
}
