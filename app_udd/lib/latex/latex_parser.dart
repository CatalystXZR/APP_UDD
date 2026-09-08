enum LatexSegmentKind { text, inline, display }

class LatexSegment {
  const LatexSegment(this.kind, this.content);

  final LatexSegmentKind kind;
  final String content;

  bool get isText => kind == LatexSegmentKind.text;
  bool get isInline => kind == LatexSegmentKind.inline;
  bool get isDisplay => kind == LatexSegmentKind.display;
}

List<LatexSegment> parseLatex(String input) {
  final out = <LatexSegment>[];
  final buf = StringBuffer();

  void flushText() {
    if (buf.isNotEmpty) {
      out.add(LatexSegment(LatexSegmentKind.text, buf.toString()));
      buf.clear();
    }
  }

  var i = 0;
  while (i < input.length) {
    if (input.startsWith('\\(', i)) {
      final end = input.indexOf('\\)', i + 2);
      if (end == -1) {
        buf.write(input.substring(i));
        break;
      }
      flushText();
      out.add(LatexSegment(LatexSegmentKind.inline, input.substring(i + 2, end)));
      i = end + 2;
    } else if (input.startsWith('\\[', i)) {
      final end = input.indexOf('\\]', i + 2);
      if (end == -1) {
        buf.write(input.substring(i));
        break;
      }
      flushText();
      out.add(LatexSegment(LatexSegmentKind.display, input.substring(i + 2, end)));
      i = end + 2;
    } else {
      buf.write(input[i]);
      i++;
    }
  }
  flushText();
  return out;
}
