import 'dart:math';

class FormulaEvaluator {
  final String _expression;
  final Map<String, dynamic> _variables;
  int _pos = 0;

  FormulaEvaluator(this._variables, this._expression);

  dynamic evaluate() {
    _pos = 0;
    final result = _parseConditional();
    _skipWhitespace();
    if (_pos < _expression.length) {
      throw FormatException(
        'Unexpected character "${_expression[_pos]}" at position $_pos',
      );
    }
    return result;
  }

  void _skipWhitespace() {
    while (_pos < _expression.length && _expression[_pos] == ' ') {
      _pos++;
    }
  }

  String _peek() {
    _skipWhitespace();
    if (_pos >= _expression.length) return '';
    return _expression[_pos];
  }

  String _advance() {
    _skipWhitespace();
    if (_pos >= _expression.length) return '';
    return _expression[_pos++];
  }

  bool _expect(String ch) {
    if (_peek() == ch) {
      _advance();
      return true;
    }
    return false;
  }

  void _consume(String ch) {
    _skipWhitespace();
    if (_pos >= _expression.length || _expression[_pos] != ch) {
      final got = _pos < _expression.length ? _expression[_pos] : 'end of input';
      throw FormatException('Expected "$ch" but got "$got" at position $_pos');
    }
    _pos++;
  }

  dynamic _parseConditional() {
    final cond = _parseOr();
    if (_peek() == '?') {
      _advance();
      final trueVal = _parseConditional();
      _consume(':');
      final falseVal = _parseConditional();
      return _isTruthy(cond) ? trueVal : falseVal;
    }
    return cond;
  }

  dynamic _parseOr() {
    var left = _parseAnd();
    while (_expression.startsWith('||', _pos)) {
      _pos += 2;
      _skipWhitespace();
      final right = _parseAnd();
      left = _isTruthy(left) || _isTruthy(right);
    }
    return left;
  }

  dynamic _parseAnd() {
    var left = _parseComparison();
    while (_expression.startsWith('&&', _pos)) {
      _pos += 2;
      _skipWhitespace();
      final right = _parseComparison();
      left = _isTruthy(left) && _isTruthy(right);
    }
    return left;
  }

  dynamic _parseComparison() {
    var left = _parseAddition();
    final op = _peek();
    if (op == '<' || op == '>' || op == '=' || op == '!') {
      String opStr;
      if (op == '<' || op == '>') {
        _advance();
        opStr = _expect('=') ? '$op=' : op;
      } else if (op == '=') {
        _advance();
        _consume('=');
        opStr = '==';
      } else {
        _advance();
        _consume('=');
        opStr = '!=';
      }
      final right = _parseAddition();
      left = _applyComparison(opStr, left, right);
    }
    return left;
  }

  dynamic _parseAddition() {
    var left = _parseMultiplication();
    while (_peek() == '+' || _peek() == '-') {
      final op = _advance();
      final right = _parseMultiplication();
      left = op == '+' ? left + right : left - right;
    }
    return left;
  }

  dynamic _parseMultiplication() {
    var left = _parsePower();
    while (_peek() == '*' || _peek() == '/') {
      final op = _advance();
      final right = _parsePower();
      left = op == '*' ? left * right : left / right;
    }
    return left;
  }

  dynamic _parsePower() {
    var left = _parseUnary();
    if (_peek() == '^') {
      _advance();
      final right = _parsePower();
      left = pow(left, right);
    }
    return left;
  }

  dynamic _parseUnary() {
    if (_peek() == '-') {
      _advance();
      final val = _parseUnary();
      if (val is num) return -val;
      throw FormatException('Cannot negate non-numeric value');
    }
    if (_peek() == '!') {
      _advance();
      final val = _parseUnary();
      return !_isTruthy(val);
    }
    return _parseCall();
  }

  dynamic _parseCall() {
    _skipWhitespace();
    if (_pos >= _expression.length) {
      throw FormatException('Unexpected end of expression');
    }
    final start = _pos;
    if (_peek() == '(') {
      _advance();
      final val = _parseConditional();
      _consume(')');
      return val;
    }
    if (_isDigit(_peek()) || _peek() == '.') {
      return _parseNumber();
    }
    final name = _parseIdentifier();
    if (_peek() == '(') {
      _advance();
      final args = <dynamic>[];
      if (_peek() != ')') {
        args.add(_parseConditional());
        while (_peek() == ',') {
          _advance();
          args.add(_parseConditional());
        }
      }
      _consume(')');
      return _callFunction(name, args);
    }
    if (_variables.containsKey(name)) {
      return _variables[name];
    }
    throw FormatException('Unknown variable "$name" at position $start');
  }

  num _parseNumber() {
    _skipWhitespace();
    final start = _pos;
    while (_pos < _expression.length &&
        (_isDigit(_expression[_pos]) || _expression[_pos] == '.')) {
      _pos++;
    }
    if (_pos == start) {
      throw FormatException('Expected number at position $start');
    }
    final str = _expression.substring(start, _pos);
    return str.contains('.') ? double.parse(str) : int.parse(str);
  }

  String _parseIdentifier() {
    _skipWhitespace();
    if (_pos >= _expression.length) return '';
    if (!_isAlpha(_expression[_pos]) && _expression[_pos] != '_') return '';
    final start = _pos;
    while (_pos < _expression.length &&
        (_isAlphaNumeric(_expression[_pos]) || _expression[_pos] == '_')) {
      _pos++;
    }
    return _expression.substring(start, _pos);
  }

  bool _isDigit(String ch) => ch.length == 1 && ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
  bool _isAlpha(String ch) {
    if (ch.length != 1) return false;
    final c = ch.codeUnitAt(0);
    return (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
  }
  bool _isAlphaNumeric(String ch) => _isAlpha(ch) || _isDigit(ch) || ch == '_';

  dynamic _applyComparison(String op, dynamic left, dynamic right) {
    if (left is num && right is num) {
      switch (op) {
        case '<': return left < right;
        case '>': return left > right;
        case '<=': return left <= right;
        case '>=': return left >= right;
        case '==': return left == right;
        case '!=': return left != right;
      }
    }
    switch (op) {
      case '==': return left == right;
      case '!=': return left != right;
      default:
        throw FormatException('Cannot compare $left and $right with $op');
    }
  }

  bool _isTruthy(dynamic val) {
    if (val is bool) return val;
    if (val is num) return val != 0;
    return val != null;
  }

  dynamic _callFunction(String name, List<dynamic> args) {
    switch (name) {
      case 'sqrt':
        if (args.length != 1) throw FormatException('sqrt takes 1 argument');
        return sqrt((args[0] as num).toDouble());
      case 'pow':
        if (args.length != 2) throw FormatException('pow takes 2 arguments');
        return pow(args[0] as num, args[1] as num);
      case 'round':
        if (args.length != 1) throw FormatException('round takes 1 argument');
        return (args[0] as num).round();
      case 'floor':
        if (args.length != 1) throw FormatException('floor takes 1 argument');
        return (args[0] as num).floor();
      case 'ceil':
        if (args.length != 1) throw FormatException('ceil takes 1 argument');
        return (args[0] as num).ceil();
      case 'abs':
        if (args.length != 1) throw FormatException('abs takes 1 argument');
        return (args[0] as num).abs();
      case 'min':
        if (args.length != 2) throw FormatException('min takes 2 arguments');
        return min(args[0] as num, args[1] as num);
      case 'max':
        if (args.length != 2) throw FormatException('max takes 2 arguments');
        return max(args[0] as num, args[1] as num);
      default:
        throw FormatException('Unknown function "$name"');
    }
  }
}
