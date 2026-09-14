import 'package:flutter_test/flutter_test.dart';
import 'package:lapiscalc/utils/exact_calculator.dart';
import 'package:rational/rational.dart';

void main() {
  test('Every digit is preserved through and beyond the plain notation limit',
      () {
    for (final literal in [
      '12345678912345666',
      '123456789123456667',
      '1234567891234566679',
      '123456789123456667912',
      '999999999999999999999',
      '12345678912345666.7',
    ]) {
      final result = ExactCalculator.evaluate(literal);
      expect(result, Rational.parse(literal));
      expect(ExactCalculator.format(result), literal);
    }
    expect(ExactCalculator.evaluate('1234567891234566679+1'),
        Rational.parse('1234567891234566680'));
    expect(ExactCalculator.evaluate('1234567891234566679*10+9'),
        Rational.parse('12345678912345666799'));
    expect(
        ExactCalculator.evaluate(
            '1000000000000000000001-1000000000000000000000'),
        Rational.one);
    expect(ExactCalculator.evaluate('0.1+0.2'), Rational.parse('0.3'));
  });

  test('Scientific notation has fixed boundaries and round-trips exactly', () {
    final cases = {
      '999999999999999999999': '999999999999999999999',
      '1000000000000000000000': '1e+21',
      '-1000000000000000000000': '-1e+21',
      '0.000001': '0.000001',
      '0.0000001': '1e-7',
      '1e+100': '1e+100',
      '1e-100': '1e-100',
      '9.999999999999999e+21': '1e+22',
    };
    for (final entry in cases.entries) {
      final result = ExactCalculator.evaluate(entry.key);
      expect(ExactCalculator.format(result), entry.value, reason: entry.key);
      expect(
          ExactCalculator.evaluate(ExactCalculator.serialize(result)), result);
    }
    final large = ExactCalculator.evaluate('1234567891234566679123');
    expect(ExactCalculator.format(large), contains('e+21'));
    expect(
        ExactCalculator.evaluate('ans-1234567891234566679122', previous: large),
        Rational.one);
  });

  test('Percentages, repeated percentages, precedence and parentheses', () {
    final cases = {
      '9%60': '5.4',
      '9%%60': '0.054',
      '9%%.5': '0.00045',
      '(2+3).5': '2.5',
      '50%%': '0.005',
      '50%%%': '0.00005',
      '100+10%': '110',
      '100-10%': '90',
      '100+10%%': '100.1',
      '200*10%%': '0.2',
      '100+(2+3)%': '105',
      '(2+3)%%': '0.0005',
      '1.2+3.4': '4.6',
      '(8+2)*3': '30',
      '2(3+4)': '14',
      '(3+4)2': '14',
      '(5+3': '8',
      '2*(-3)': '-6',
      '2^3^2': '512',
      '1/3*3': '1',
    };
    for (final entry in cases.entries) {
      expect(ExactCalculator.evaluate(entry.key), Rational.parse(entry.value),
          reason: entry.key);
    }
  });

  test('Incomplete expressions and division by zero fail explicitly', () {
    for (final expression in ['1+', '12..3', '(1+)', '1/0', '0/0', ')1(']) {
      expect(() => ExactCalculator.evaluate(expression), throwsFormatException,
          reason: expression);
    }
  });
}
