class FamilySpec {
  const FamilySpec({
    required this.id,
    required this.levelKey,
    required this.familyIndex,
    required this.generatorKey,
    required this.title,
    required this.tuples,
    this.domain,
  });

  final String id;
  final String levelKey;
  final int familyIndex;
  final String generatorKey;
  final String title;
  final List<Map<String, dynamic>> tuples;
  final Map<String, dynamic>? domain;

  factory FamilySpec.fromMap(Map<String, dynamic> m) {
    return FamilySpec(
      id: m['id'] as String,
      levelKey: m['level_key'] as String? ?? m['levelKey'] as String,
      familyIndex: (m['family_index'] as num? ?? m['familyIndex'] as num).toInt(),
      generatorKey: m['generator_key'] as String? ?? m['generatorKey'] as String,
      title: m['title'] as String? ?? '',
      tuples: ((m['tuples_json'] as List?) ?? (m['tuples'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      domain: m['domain_json'] as Map<String, dynamic>?,
    );
  }
}
