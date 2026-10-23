// lib/secure_math_engine.dart
import 'dart:math' as math;

class SecureMathEngine {
  static final Set<String> _allowedFunctions = {
    'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
    'sqrt', 'ln', 'log', 'abs'
  };

  static String evaluate(String expression, {bool isRadian = true}) {
    if (expression.trim().isEmpty) return '0';
    try {
      final sanitized = expression
          .replaceAll('π', '${math.pi}')
          .replaceAll('pi', '${math.pi}')
          .replaceAll('e', '${math.e}');

      final tokens = _tokenize(sanitized);
      final parser = _RecursiveDescentParser(tokens, isRadian);
      final value = parser.parse();

      if (value.isNaN || value.isInfinite) return 'Math Error';
      if (value == value.roundToDouble()) return value.toInt().toString();
      return value.toStringAsFixed(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    } catch (e) {
      return 'Syntax Error';
    }
  }

  static List<_Token> _tokenize(String input) {
    final tokens = <_Token>[];
    int i = 0;
    while (i < input.length) {
      final ch = input[i];
      if (ch.trim().isEmpty) { i++; continue; }
      if (RegExp(r'[0-9.]').hasMatch(ch)) {
        var numStr = '';
        while (i < input.length && RegExp(r'[0-9.]').hasMatch(input[i])) {
          numStr += input[i++];
        }
        tokens.add(_Token(_TokenType.number, numStr));
        continue;
      }
      if (RegExp(r'[a-zA-Z]').hasMatch(ch)) {
        var fn = '';
        while (i < input.length && RegExp(r'[a-zA-Z]').hasMatch(input[i])) {
          fn += input[i++];
        }
        if (_allowedFunctions.contains(fn.toLowerCase())) {
          tokens.add(_Token(_TokenType.function, fn.toLowerCase()));
        } else {
          throw FormatException('Disallowed function: $fn');
        }
        continue;
      }
      if (ch == '(') { tokens.add(_Token(_TokenType.lParen, '(')); i++; continue; }
      if (ch == ')') { tokens.add(_Token(_TokenType.rParen, ')')); i++; continue; }
      if ('+-*/^%!'.contains(ch)) { tokens.add(_Token(_TokenType.op, ch)); i++; continue; }
      throw FormatException('Invalid symbol: $ch');
    }
    return tokens;
  }
}

enum _TokenType { number, op, function, lParen, rParen }
class _Token {
  final _TokenType type;
  final String value;
  _Token(this.type, this.value);
}

class _RecursiveDescentParser {
  final List<_Token> tokens;
  final bool isRadian;
  int _pos = 0;
  _RecursiveDescentParser(this.tokens, this.isRadian);

  _Token? _peek() => _pos < tokens.length ? tokens[_pos] : null;
  _Token _consume() => tokens[_pos++];

  double parse() {
    final res = _parseExpr();
    if (_pos < tokens.length) throw FormatException('Unexpected token');
    return res;
  }

  double _parseExpr() {
    var val = _parseTerm();
    while (_peek()?.type == _TokenType.op && (_peek()?.value == '+' || _peek()?.value == '-')) {
      final op = _consume().value;
      final right = _parseTerm();
      val = op == '+' ? val + right : val - right;
    }
    return val;
  }

  double _parseTerm() {
    var val = _parseFactor();
    while (_peek()?.type == _TokenType.op && '*/%'.contains(_peek()!.value)) {
      final op = _consume().value;
      final right = _parseFactor();
      if (op == '*') val *= right;
      if (op == '/') { if (right == 0) throw StateError('Zero division'); val /= right; }
      if (op == '%') val %= right;
    }
    return val;
  }

  double _parseFactor() {
    var base = _parseUnary();
    if (_peek()?.type == _TokenType.op && _peek()?.value == '^') {
      _consume();
      final exp = _parseFactor();
      base = math.pow(base, exp).toDouble();
    }
    return base;
  }

  double _parseUnary() {
    if (_peek()?.type == _TokenType.op && _peek()?.value == '+') { _consume(); return _parseUnary(); }
    if (_peek()?.type == _TokenType.op && _peek()?.value == '-') { _consume(); return -_parseUnary(); }
    return _parsePrimary();
  }

  double _parsePrimary() {
    final t = _peek();
    if (t == null) throw StateError('Expected value');
    if (t.type == _TokenType.number) { _consume(); return double.parse(t.value); }
    if (t.type == _TokenType.function) {
      final fn = _consume().value;
      _consume();
      final arg = _parseExpr();
      _consume();
      final rad = isRadian ? arg : (arg * math.pi / 180.0);
      switch (fn) {
        case 'sin': return math.sin(rad);
        case 'cos': return math.cos(rad);
        case 'tan': return math.tan(rad);
        case 'sqrt': return math.sqrt(arg);
        case 'ln': return math.log(arg);
        case 'log': return math.log(arg) / math.ln10;
        case 'abs': return arg.abs();
        default: throw UnimplementedError(fn);
      }
    }
    if (t.type == _TokenType.lParen) {
      _consume();
      final val = _parseExpr();
      _consume();
      return val;
    }
    throw FormatException('Unexpected token: ${t.value}');
  }
}
