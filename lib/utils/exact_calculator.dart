import 'package:math_expressions/math_expressions.dart';
import 'package:rational/rational.dart';

/// Basic arithmetic never passes through double, including numeric literals.
class ExactCalculator {
  static final _scientific = RegExp(r'(\d+(?:\.\d*)?|\.\d+)[eE]([+\-]?\d+)');
  static final _ten = Rational.fromInt(10);
  static final _large = _ten.pow(21);
  static final _small = _ten.pow(-6);

  static Rational evaluate(String input, {Rational? previous}) {
    var expression =
        input.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('–', '-');
    var balance = 0;
    for (final char in expression.split('')) {
      if (char == '(') balance++;
      if (char == ')') balance--;
      if (balance < 0) throw const FormatException('Unmatched parenthesis');
    }
    expression += ')' * balance;
    expression = _percentages(expression);
    expression = expression.replaceAllMapped(_scientific, (match) {
      final exponent = int.parse(match[2]!);
      if (exponent.abs() > 10000) {
        throw const FormatException('Exponent too large');
      }
      return '(${match[1]}*10^$exponent)';
    });
    expression = expression.replaceAll(
        RegExp(r'(?<=[\d)])(?=\()|(?<=\))(?=[\d.])'), '*');
    final stack = <Rational>[];
    Rational pop() {
      if (stack.isEmpty) throw const FormatException('Missing operand');
      return stack.removeLast();
    }

    // Reuse the existing lexer for precedence, but read the original digit
    // strings instead of Parser's double-valued Number nodes.
    for (final token in Lexer().tokenizeToRPN(expression)) {
      switch (token.type) {
        case TokenType.VAL:
          stack.add(Rational.parse(token.text));
          break;
        case TokenType.VAR:
          if (token.text != 'ans' || previous == null) {
            throw const FormatException('Unknown variable');
          }
          stack.add(previous);
          break;
        case TokenType.UNMINUS:
          stack.add(-pop());
          break;
        case TokenType.UNPLUS:
          stack.add(pop());
          break;
        case TokenType.PLUS:
        case TokenType.MINUS:
        case TokenType.TIMES:
        case TokenType.DIV:
        case TokenType.POW:
          final right = pop();
          final left = pop();
          if (token.type == TokenType.PLUS) {
            stack.add(left + right);
          } else if (token.type == TokenType.MINUS) {
            stack.add(left - right);
          } else if (token.type == TokenType.TIMES) {
            stack.add(left * right);
          } else if (token.type == TokenType.DIV) {
            if (right == Rational.zero) {
              throw const FormatException('Division by zero');
            }
            stack.add(left / right);
          } else {
            if (!right.isInteger || right.abs() > Rational.fromInt(10000)) {
              throw const FormatException('Unsupported exponent');
            }
            stack.add(left.pow(right.toBigInt().toInt()));
          }
          break;
        default:
          throw const FormatException('Unsupported operation');
      }
    }
    if (stack.length != 1) throw const FormatException('Invalid expression');
    return stack.single;
  }

  static String _percentages(String input) {
    const operand = r'(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+\-]?\d+)?|\([^()]+\)';
    // Keep the app's infix percentage (9%60), commercial percentage
    // (100+10%), and repeated postfix percentages (50%%).
    var result = input.replaceAllMapped(
      RegExp('($operand)(%+)(?=[\\d.(])'),
      (m) => '(${m[1]}/100^${m[2]!.length})*',
    );
    final commercial = RegExp('($operand)\\s*([+\\-])\\s*($operand)(%+)');
    while (commercial.hasMatch(result)) {
      result = result.replaceAllMapped(commercial,
          (m) => '${m[1]}${m[2]}(${m[1]}*${m[3]}/100^${m[4]!.length})');
    }
    result = result.replaceAllMapped(
        RegExp('($operand)(%+)'), (m) => '(${m[1]}/100^${m[2]!.length})');
    return result.replaceAll('%', '/100');
  }

  /// Full integer digits below 10^21; scientific notation is display-only.
  static String format(Rational value) {
    if (value == Rational.zero) return '0';
    final magnitude = value.abs();
    if (magnitude >= _large || magnitude < _small) {
      var exponent = magnitude.numerator.toString().length -
          magnitude.denominator.toString().length;
      if (magnitude < _ten.pow(exponent)) exponent--;
      var mantissa = value / _ten.pow(exponent);
      var text = _fixed(mantissa, 14);
      if (Rational.parse(text).abs() >= _ten) {
        exponent++;
        mantissa /= _ten;
        text = _fixed(mantissa, 14);
      }
      return '${text}e${exponent >= 0 ? '+' : ''}$exponent';
    }
    return _fixed(value, 15);
  }

  static String _fixed(Rational value, int places) {
    final scale = BigInt.from(10).pow(places);
    final scaled = (value * Rational(scale)).round();
    final digits = scaled.abs().toString().padLeft(places + 1, '0');
    final whole = digits.substring(0, digits.length - places);
    final fraction = digits
        .substring(digits.length - places)
        .replaceFirst(RegExp(r'0+$'), '');
    return '${scaled.isNegative ? '-' : ''}$whole${fraction.isEmpty ? '' : '.$fraction'}';
  }

  static String serialize(Rational value) => value.isInteger
      ? value.numerator.toString()
      : '(${value.numerator}/${value.denominator})';
}
