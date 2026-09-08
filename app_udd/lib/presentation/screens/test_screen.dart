import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../latex/latex_text.dart';
import '../controllers/test_controller.dart';
import '../widgets/option_card.dart';
import '../widgets/timer_ring.dart';

class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(testControllerProvider);
    final controller = ref.read(testControllerProvider.notifier);

    if (state.phase == TestPhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/result');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(state.phase == TestPhase.ready
            ? 'Pregunta ${state.currentIndex + 1}'
            : 'Prueba'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => _confirmExit(context, controller),
            child: const Text('Salir',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: switch (state.phase) {
        TestPhase.loading || TestPhase.idle => const Center(
            child: CircularProgressIndicator(),
          ),
        _ => _body(context, state, controller),
      },
    );
  }

  Widget _body(BuildContext context, TestState state,
      TestController controller) {
    final q = state.current;
    if (q == null) {
      return const Center(child: Text('Sin preguntas disponibles'));
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TestController.levelLabels(state.levelKey),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                        ),
                        const Text(
                          'Sucesiones y Límites',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  TimerRing(
                    secondsLeft: state.secondsLeft,
                    total: state.secondsPerQuestion,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LatexText(q.text,
                      textStyle: const TextStyle(fontSize: 17)),
                ),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < q.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OptionCard(
                    letter: String.fromCharCode(65 + i),
                    text: q.options[i],
                    selected: state.selected == i,
                    onTap: () => controller.select(i),
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.selected == null
                        ? null
                        : controller.confirm,
                    child: const Text('Confirmar respuesta'),
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: state.progress),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmExit(
      BuildContext context, TestController controller) async {
    controller.pause();
    final exit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Salir de la prueba?'),
        content:
            const Text('El progreso de esta prueba se perderá.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
    if (exit == true) {
      controller.abort();
      if (context.mounted) context.go('/');
    } else {
      controller.resume();
    }
  }
}
