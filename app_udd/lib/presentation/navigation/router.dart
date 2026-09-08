import 'package:go_router/go_router.dart';

import '../screens/levels_screen.dart';
import '../screens/welcome_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/levels', builder: (context, state) => const LevelsScreen()),
    ],
  );
}
