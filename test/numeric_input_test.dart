import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lapiscalc/pages/pages.dart';
import 'package:lapiscalc/utils/numeric_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'calculation_regressions_test.dart'
    show testApp, press, numericFields, fieldText;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('One decimal per operand and no consecutive arithmetic operators', () {
    const formatter = NumericInputFormatter(expression: true);
    for (final valid in [
      '',
      '-',
      '-1.2',
      '1.2+3.4',
      '2*(-3.4)',
      '1e-7+2e+3',
      '50%%',
      '50%%+2',
      '9%%60',
      '0.5*(1.2+3.4)',
    ]) {
      expect(formatter.accepts(valid), isTrue, reason: valid);
    }
    for (final invalid in [
      '1..2',
      '1.2+3.4.5',
      '1e2.3',
      '1.2e-3.4',
      '2*/',
      '2×÷',
      '2+-',
      '2--',
      '2+*3',
      '2+ *3',
    ]) {
      expect(formatter.accepts(invalid), isFalse, reason: invalid);
    }
  });

  test('Selection replacement and insertion in the middle respect each operand',
      () {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    controller.value = const TextEditingValue(
        text: '1.2+34', selection: TextSelection.collapsed(offset: 1));
    insertNumericText(controller, '.', expression: true);
    expect(controller.text, '1.2+34');
    expect(controller.selection.baseOffset, 1);
    controller.selection = const TextSelection.collapsed(offset: 5);
    insertNumericText(controller, '.', expression: true);
    expect(controller.text, '1.2+3.4');
    controller.selection = const TextSelection(baseOffset: 1, extentOffset: 2);
    insertNumericText(controller, '.', expression: true);
    expect(controller.text, '1.2+3.4');
    controller.selection = const TextSelection(baseOffset: 3, extentOffset: 4);
    insertNumericText(controller, '*', expression: true);
    expect(controller.text, '1.2*3.4');
    controller.selection = const TextSelection.collapsed(offset: 4);
    insertNumericText(controller, '/', expression: true);
    expect(controller.text, '1.2*3.4');
  });

  testWidgets('Large digits typed after equals do not turn into zeros',
      (tester) async {
    await tester.pumpWidget(testApp(const StdCalc()));
    await tester.pumpAndSettle();
    var expected = '12345678912345666';
    await tester.enterText(numericFields, expected);
    await press(tester, '=');
    expect(fieldText(tester, numericFields), expected);
    for (final digit in ['7', '9', '1', '2']) {
      expected += digit;
      await press(tester, digit);
      expect(fieldText(tester, numericFields), expected);
      await press(tester, '=');
      expect(fieldText(tester, numericFields), expected);
    }
    await press(tester, '3');
    await press(tester, '=');
    expect(fieldText(tester, numericFields), contains('e+21'));
    await press(tester, '–');
    // The rounded scientific display must not become the next numeric value.
    for (final digit in '1234567891234566679122'.split('')) {
      await press(tester, digit);
    }
    await press(tester, '=');
    expect(fieldText(tester, numericFields), '1');
  });

  testWidgets(
      'Calculator keypad blocks duplicate dots/operators but permits %%',
      (tester) async {
    await tester.pumpWidget(testApp(const StdCalc()));
    await tester.pumpAndSettle();
    for (final key in [
      '1',
      '.',
      '.',
      '2',
      '×',
      '÷',
      '+',
      '–',
      '3',
      '.',
      '.',
      '4'
    ]) {
      await press(tester, key);
    }
    expect(fieldText(tester, numericFields), '1.2×3.4');
    await press(tester, '=');
    expect(fieldText(tester, numericFields), '4.08');
    await press(tester, 'C');
    await tester.enterText(numericFields, '1.2+3.4');
    await tester.enterText(numericFields, '1.2+3..4');
    expect(fieldText(tester, numericFields), '1.2+3.4');
    await press(tester, '=');
    expect(fieldText(tester, numericFields), '4.6');
    await press(tester, 'C');
    for (final key in ['5', '0', '%', '%']) {
      await press(tester, key);
    }
    expect(fieldText(tester, numericFields), '50%%');
    await press(tester, '=');
    expect(fieldText(tester, numericFields), '0.005');
  });

  for (final converter in <Widget>[
    const AngleConv(),
    const AreaConv(),
    const DataConv(),
    const EnergyConv(),
    const LengthConv(),
    const MassConv(),
    const PowerConv(),
    const PressureConv(),
    const SpeedConv(),
    const TemperatureConv(),
    const TimeConv(),
    const VolumeConv(),
    const TipConv(),
  ]) {
    testWidgets(
        '${converter.runtimeType} prevents a second decimal from the keypad',
        (tester) async {
      await tester.pumpWidget(testApp(converter));
      await tester.pumpAndSettle();
      for (final field in [numericFields.first, numericFields.at(1)]) {
        await tester.enterText(field, '1.2');
        await tester.pumpAndSettle();
        await press(tester, '.');
        expect(fieldText(tester, field), '1.2');
        await press(tester, '3');
        expect(fieldText(tester, field), '1.23');
        await tester.enterText(field, '1.2.3');
        expect(fieldText(tester, field), '1.23');
        expect(tester.takeException(), isNull);
      }
    });
  }
}
