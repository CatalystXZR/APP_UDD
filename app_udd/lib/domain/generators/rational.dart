int _gcd(int a, int b) {
  a = a.abs();
  b = b.abs();
  while (b != 0) {
    final t = b;
    b = a % b;
    a = t;
  }
  return a == 0 ? 1 : a;
}

class Rational {
  final int n;
  final int d;

  const Rational._(this.n, this.d);

  factory Rational(int n, [int d = 1]) {
    if (d == 0) throw ArgumentError('Denominador cero');
    if (d < 0) {
      n = -n;
      d = -d;
    }
    final g = _gcd(n, d);
    return Rational._(n ~/ g, d ~/ g);
  }

  Rational operator +(Rational o) => Rational(n * o.d + o.n * d, d * o.d);
  Rational operator -(Rational o) => Rational(n * o.d - o.n * d, d * o.d);
  Rational operator *(Rational o) => Rational(n * o.n, d * o.d);
  Rational operator /(Rational o) => Rational(n * o.d, d * o.n);
  Rational neg() => Rational._(-n, d);

  bool get isZero => n == 0;
  bool get isOne => n == d;
  bool get isMinusOne => n == -d;
  bool get isNegative => n < 0;

  Rational abs() => isNegative ? neg() : this;

  String toLatex() {
    if (d == 1) return '$n';
    return '${isNegative ? '-' : ''}\\frac{${n.abs()}}{$d}';
  }

  String timesX() {
    if (isOne) return 'x';
    if (isMinusOne) return '-x';
    return '${toLatex()}x';
  }

  @override
  bool operator ==(Object other) =>
      other is Rational && n == other.n && d == other.d;

  @override
  int get hashCode => Object.hash(n, d);

  @override
  String toString() => d == 1 ? '$n' : '$n/$d';
}
