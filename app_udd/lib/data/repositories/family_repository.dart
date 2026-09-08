import 'dart:convert';

import '../models/family_spec.dart';
import '../supabase_client.dart';

class FamilyRepository {
  Future<List<FamilySpec>> load() async {
    try {
      if (supabaseReady) {
        final rows = await supabase.from('families').select().order('id');
        return (rows as List)
            .map((e) => FamilySpec.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}
    throw StateError('Catálogo remoto no disponible; usar seed local');
  }

  static List<FamilySpec> parseSeed(String json) {
    final doc = jsonDecode(json) as Map<String, dynamic>;
    final out = <FamilySpec>[];
    for (final lv in doc['levels'] as List) {
      final level = lv as Map<String, dynamic>;
      for (final f in level['families'] as List) {
        final fam = f as Map<String, dynamic>;
        out.add(FamilySpec(
          id: '${level['key']}-f${fam['family_index']}',
          levelKey: level['key'] as String,
          familyIndex: (fam['family_index'] as num).toInt(),
          generatorKey: fam['generator_key'] as String,
          title: fam['title'] as String? ?? '',
          tuples: (fam['tuples'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList(),
          domain: fam['domain'] as Map<String, dynamic>?,
        ));
      }
    }
    return out;
  }
}
