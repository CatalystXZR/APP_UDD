import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/test_controller.dart';
import '../logic/test_scoring.dart';

class LevelsScreen extends ConsumerWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona la dificultad'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: levelKeys.length,
        itemBuilder: (context, i) {
          final key = levelKeys[i];
          final label = TestController.levelLabels(key);
          final seconds = AppConstants.secondsPerQuestion[label]!;
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              title: Text(
                label,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                  '${levelDescriptions[key]}\n$seconds segundos por pregunta'),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.azul),
              onTap: () {
                ref.read(selectedLevelProvider.notifier).select(key);
                context.go('/courses');
              },
            ),
          );
        },
      ),
    );
  }
}
