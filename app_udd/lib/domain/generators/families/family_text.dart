String pnTerm(int p) {
  if (p == 1) return 'n';
  if (p == -1) return '-n';
  return '${p}n';
}

String signedTerm(int v) => v >= 0 ? '+$v' : '$v';
