import 'package:bvo_matematica/latex/latex_normalize.dart';
import 'package:bvo_matematica/latex/latex_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseLatex', () {
    test('texto plano sin matematica', () {
      final segs = parseLatex('Hola mundo');
      expect(segs.length, 1);
      expect(segs.first.kind, LatexSegmentKind.text);
    });

    test('inline simple', () {
      final segs = parseLatex(r'Calcule \(x+1\) por favor');
      expect(segs.length, 3);
      expect(segs[0].kind, LatexSegmentKind.text);
      expect(segs[1].kind, LatexSegmentKind.inline);
      expect(segs[1].content, 'x+1');
      expect(segs[2].kind, LatexSegmentKind.text);
    });

    test('display simple', () {
      final segs = parseLatex(r'\[a_n=pn+q\]');
      expect(segs.length, 1);
      expect(segs.first.kind, LatexSegmentKind.display);
      expect(segs.first.content, 'a_n=pn+q');
    });

    test('mixto inline + display', () {
      final segs = parseLatex(r'Si \(p>0\) crece. \[\lim e_n=a/c\] Fin.');
      expect(segs.map((s) => s.kind), [
        LatexSegmentKind.text,
        LatexSegmentKind.inline,
        LatexSegmentKind.text,
        LatexSegmentKind.display,
        LatexSegmentKind.text,
      ]);
    });

    test('delimitador sin cerrar se degrada a texto', () {
      final segs = parseLatex(r'Valor \(x+1 sin cerrar');
      expect(segs.every((s) => s.kind == LatexSegmentKind.text), isTrue);
      expect(segs.map((s) => s.content).join(), r'Valor \(x+1 sin cerrar');
    });

    test('vacio', () {
      expect(parseLatex(''), isEmpty);
    });
  });

  group('normalizeLatex', () {
    test('colapsa espacios', () {
      expect(normalizeLatex('  a   +  b  '), 'a + b');
    });

    test('despoja cancel como el limpiador del HTML', () {
      expect(normalizeLatex(r'\frac{\cancel{x}}{2}'), r'\frac{x}{2}');
    });

    test('stripOuterMath', () {
      expect(stripOuterMath(r'\(x+1\)'), 'x+1');
      expect(stripOuterMath(r'\[x+1\]'), 'x+1');
      expect(stripOuterMath('x+1'), 'x+1');
    });
  });
}
