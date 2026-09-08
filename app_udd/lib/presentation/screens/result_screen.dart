import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../controllers/test_controller.dart';
import '../widgets/grade_circle.dart';
import '../widgets/pauta_panel.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  var showPauta = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(testControllerProvider);
    final controller = ref.read(testControllerProvider.notifier);
    final n = state.correctCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba finalizada'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: Text('BVO',
                style: TextStyle(
                  color: AppColors.azul,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                )),
          ),
          const SizedBox(height: 12),
          Text(
            'Obtuviste $n ${n == 1 ? 'respuesta correcta' : 'respuestas correctas'}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 20),
          Center(child: GradeCircle(correctCount: n)),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () {
              unawaited(controller.restart());
              context.go('/test');
            },
            child: const Text('Nueva prueba'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () =>
                setState(() => showPauta = !showPauta),
            child: Text(showPauta ? 'Ocultar pauta' : 'Ver pauta'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              controller.abort();
              context.go('/');
            },
            child: const Text('← Volver al inicio'),
          ),
          if (showPauta) PautaPanel(questions: state.pauta),
        ],
      ),
    );
  }
}
