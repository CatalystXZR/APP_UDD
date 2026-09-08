import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/test_controller.dart';

class ContentsScreen extends ConsumerWidget {
  const ContentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona el contenido'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/courses'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              'CÁLCULO DIFERENCIAL',
              style: TextStyle(
                color: AppColors.gris,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              title: const Text(AppConstants.content,
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              subtitle: const Text(
                  'Términos, monotonía, cotas y límites'),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.azul),
              onTap: () => _openPretestDialog(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPretestDialog(
      BuildContext context, WidgetRef ref) async {
    final levelKey = ref.read(selectedLevelProvider);
    final seconds =
        AppConstants.secondsPerQuestion[TestController.levelLabels(levelKey)]!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Antes de comenzar'),
        content: Text(
            'Dispondrás de $seconds segundos por pregunta. Nivel ${TestController.levelLabels(levelKey).toLowerCase()}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Comenzar'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      unawaited(ref.read(testControllerProvider.notifier).start(levelKey));
      context.go('/test');
    }
  }
}
