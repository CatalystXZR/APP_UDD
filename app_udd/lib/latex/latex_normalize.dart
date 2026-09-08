String normalizeLatex(String raw) {
  var s = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  s = s.replaceAllMapped(RegExp(r'\\cancel\{([^{}]*)\}'), (m) => m.group(1) ?? '');
  return s.trim();
}

String stripOuterMath(String s) {
  s = s.trim();
  if (s.startsWith(r'\(') && s.endsWith(r'\)') && s.length >= 4) {
    return s.substring(2, s.length - 2);
  }
  if (s.startsWith(r'\[') && s.endsWith(r'\]') && s.length >= 4) {
    return s.substring(2, s.length - 2);
  }
  return s;
}
