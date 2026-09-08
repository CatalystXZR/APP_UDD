import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/family_spec.dart';
import '../../data/repositories/family_repository.dart';
import '../../data/seed/families_seed_data.dart';
import '../../domain/entities/question.dart';
import '../../domain/generators/test_assembler.dart';

enum TestPhase { idle, loading, ready, finished }

class TestState {
  const TestState({
    this.phase = TestPhase.idle,
    this.questions = const [],
    this.pauta = const [],
    this.currentIndex = 0,
    this.selected,
    this.correctCount = 0,
    this.secondsLeft = 0,
    this.secondsPerQuestion = 60,
    this.levelKey = 'basico',
  });

  final TestPhase phase;
  final List<Question> questions;
  final List<Question> pauta;
  final int currentIndex;
  final int? selected;
  final int correctCount;
  final int secondsLeft;
  final int secondsPerQuestion;
  final String levelKey;

  Question? get current =>
      questions.isEmpty ? null : questions[currentIndex.clamp(0, questions.length - 1)];

  double get progress =>
      questions.isEmpty ? 0 : currentIndex / questions.length;

  TestState copyWith({
    TestPhase? phase,
    List<Question>? questions,
    List<Question>? pauta,
    int? currentIndex,
    int? selected,
    bool clearSelected = false,
    int? correctCount,
    int? secondsLeft,
    int? secondsPerQuestion,
    String? levelKey,
  }) {
    return TestState(
      phase: phase ?? this.phase,
      questions: questions ?? this.questions,
      pauta: pauta ?? this.pauta,
      currentIndex: currentIndex ?? this.currentIndex,
      selected: clearSelected ? null : (selected ?? this.selected),
      correctCount: correctCount ?? this.correctCount,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      secondsPerQuestion: secondsPerQuestion ?? this.secondsPerQuestion,
      levelKey: levelKey ?? this.levelKey,
    );
  }
}

class SelectedLevel extends Notifier<String> {
  @override
  String build() => 'basico';

  void select(String key) => state = key;
}

final selectedLevelProvider =
    NotifierProvider<SelectedLevel, String>(SelectedLevel.new);

class TestController extends Notifier<TestState> {
  Timer? _timer;
  final Map<String, List<String>> _memory = {};
  List<FamilySpec>? _specs;

  @override
  TestState build() {
    ref.onDispose(() => _timer?.cancel());
    return const TestState();
  }

  Future<List<FamilySpec>> _loadSpecs() async {
    if (_specs != null) return _specs!;
    final repo = FamilyRepository();
    try {
      _specs = await repo.load();
    } catch (_) {
      _specs = FamilyRepository.parseSeed(familiesSeedJson);
    }
    return _specs!;
  }

  int _secondsFor(String levelKey) =>
      AppConstants.secondsPerQuestion[levelLabels(levelKey)] ?? 60;

  static String levelLabels(String key) =>
      {'basico': 'Básico', 'medio': 'Medio', 'experto': 'Experto'}[key]!;

  Future<void> start(String levelKey) async {
    _timer?.cancel();
    state = state.copyWith(
      phase: TestPhase.loading,
      levelKey: levelKey,
      secondsPerQuestion: _secondsFor(levelKey),
    );
    final specs = await _loadSpecs();
    final questions = TestAssembler().build(
      levelKey: levelKey,
      specs: specs,
      rng: Random(),
      memory: _memory,
    );
    state = TestState(
      phase: TestPhase.ready,
      questions: questions,
      pauta: List.of(questions),
      secondsPerQuestion: _secondsFor(levelKey),
      secondsLeft: _secondsFor(levelKey),
      levelKey: levelKey,
    );
    _startTimer();
  }

  Future<void> restart() => start(state.levelKey);

  void select(int index) {
    if (state.phase != TestPhase.ready) return;
    state = state.copyWith(selected: index);
  }

  void confirm() {
    if (state.phase != TestPhase.ready || state.selected == null) return;
    final q = state.current!;
    final hit = state.selected == q.correct;
    _advance(hit: hit);
  }

  void pause() => _timer?.cancel();

  void resume() {
    if (state.phase == TestPhase.ready) _startTimer();
  }

  void abort() {
    _timer?.cancel();
    state = const TestState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsLeft <= 1) {
        _advance(hit: false);
      } else {
        state = state.copyWith(secondsLeft: state.secondsLeft - 1);
      }
    });
  }

  void _advance({required bool hit}) {
    _timer?.cancel();
    final next = state.currentIndex + 1;
    if (next >= state.questions.length) {
      state = state.copyWith(
        phase: TestPhase.finished,
        correctCount: state.correctCount + (hit ? 1 : 0),
      );
      return;
    }
    state = state.copyWith(
      currentIndex: next,
      clearSelected: true,
      correctCount: state.correctCount + (hit ? 1 : 0),
      secondsLeft: state.secondsPerQuestion,
    );
    _startTimer();
  }
}

final testControllerProvider =
    NotifierProvider<TestController, TestState>(TestController.new);
