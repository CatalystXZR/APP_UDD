import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'latex_normalize.dart';
import 'latex_parser.dart';

class LatexText extends StatelessWidget {
  const LatexText(
    this.source, {
    super.key,
    this.textStyle,
    this.textAlign = TextAlign.start,
    this.displayPadding = const EdgeInsets.symmetric(vertical: 8),
  });

  final String source;
  final TextStyle? textStyle;
  final TextAlign textAlign;
  final EdgeInsetsGeometry displayPadding;

  @override
  Widget build(BuildContext context) {
    final base = textStyle ?? DefaultTextStyle.of(context).style;
    final blocks = <Widget>[];
    var current = <InlineSpan>[];

    void flushParagraph() {
      if (current.isNotEmpty) {
        blocks.add(
          RichText(
            textAlign: textAlign,
            text: TextSpan(style: base, children: List.of(current)),
          ),
        );
        current = [];
      }
    }

    Widget fallback(String expr) => Text(
          '($expr)',
          style: base.copyWith(color: base.color?.withValues(alpha: 0.7)),
        );

    for (final seg in parseLatex(source)) {
      if (seg.isText) {
        current.add(TextSpan(text: seg.content));
      } else if (seg.isInline) {
        final expr = normalizeLatex(seg.content);
        if (expr.isEmpty) continue;
        current.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              expr,
              mathStyle: MathStyle.text,
              textStyle: base,
              onErrorFallback: (_) => fallback(expr),
            ),
          ),
        );
      } else {
        flushParagraph();
        final expr = normalizeLatex(seg.content);
        if (expr.isEmpty) continue;
        blocks.add(
          Padding(
            padding: displayPadding,
            child: Center(
              child: Math.tex(
                expr,
                mathStyle: MathStyle.display,
                textStyle: base,
                onErrorFallback: (_) => fallback(expr),
              ),
            ),
          ),
        );
      }
    }
    flushParagraph();

    if (blocks.isEmpty) return const SizedBox.shrink();
    if (blocks.length == 1) return blocks.first;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: blocks,
    );
  }
}
