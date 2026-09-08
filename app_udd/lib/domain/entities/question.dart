class Question {
  const Question({
    required this.familyId,
    required this.level,
    required this.text,
    required this.options,
    required this.correct,
    required this.solution,
    this.meta = const {},
  });

  final String familyId;
  final String level;
  final String text;
  final List<String> options;
  final int correct;
  final List<String> solution;
  final Map<String, Object?> meta;

  String get correctText => options[correct];
}
