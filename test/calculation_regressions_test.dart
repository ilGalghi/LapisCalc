import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapiscalc/l10n/app_localizations.dart';
import 'package:lapiscalc/models/settings_model.dart';
import 'package:lapiscalc/pages/pages.dart';

Widget testApp(Widget child, {SettingsModel? settings}) =>
    ChangeNotifierProvider.value(
      value: settings ?? SettingsModel(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      ),
    );

Finder get numericFields => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.textAlign == TextAlign.right,
);

String fieldText(WidgetTester tester, Finder finder) =>
    tester.widget<TextField>(finder).controller!.text;

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(FilledButton, label));
  await tester.pumpAndSettle();
}

Future<void> chooseDate(WidgetTester tester, int index, String date) async {
  await tester.tap(find.byType(Chip).at(index));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Switch to input'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), date);
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Large integers and chained results retain numeric precision', (
    tester,
  ) async {
    await tester.pumpWidget(testApp(const StdCalc()));
    await tester.pumpAndSettle();
    await tester.enterText(numericFields, '1234567890123');
    await press(tester, '=');
    expect(fieldText(tester, numericFields), '1234567890123');
    await press(tester, '+');
    await press(tester, '1');
    await press(tester, '=');
    expect(fieldText(tester, numericFields), '1234567890124');

    await press(tester, 'C');
    await tester.enterText(numericFields, '1/3');
    await press(tester, '=');
    expect(fieldText(tester, numericFields), '0.333333333333333');
    await press(tester, '×');
    await press(tester, '3');
    await press(tester, '=');
    expect(fieldText(tester, numericFields), '1');

    final prefs = await SharedPreferences.getInstance();
    final history = jsonDecode(prefs.getString('history_key')!) as List;
    final lastExpression = history.last['input'] as String;
    expect(lastExpression, isNot(contains('ans')));
    await press(tester, 'C');
    await tester.enterText(numericFields, lastExpression);
    await press(tester, '=');
    expect(fieldText(tester, numericFields), '1');
  });

  testWidgets(
    'Editing and clearing a displayed result discard its cached value',
    (tester) async {
      await tester.pumpWidget(testApp(const StdCalc()));
      await tester.pumpAndSettle();
      await tester.enterText(numericFields, '1/3');
      await press(tester, '=');
      await tester.enterText(numericFields, '0.3*3');
      await press(tester, '=');
      expect(fieldText(tester, numericFields), '0.9');
      await press(tester, 'C');
      await tester.enterText(numericFields, '10+20%');
      await press(tester, '=');
      expect(fieldText(tester, numericFields), '12');
      await press(tester, '+');
      await press(tester, '1');
      await press(tester, '0');
      await press(tester, '%');
      await press(tester, '=');
      expect(fieldText(tester, numericFields), '13.2');
    },
  );

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
  ]) {
    testWidgets(
      '${converter.runtimeType} clears invalid results in both directions',
      (tester) async {
        await tester.pumpWidget(testApp(converter));
        await tester.pumpAndSettle();
        for (final reverse in [false, true]) {
          final source = reverse ? numericFields.last : numericFields.first;
          final target = reverse ? numericFields.first : numericFields.last;
          for (final invalid in [
            '12..3',
            '.',
            '-',
            'NaN',
            'Infinity',
            '1e999',
            '',
          ]) {
            await tester.enterText(source, '12');
            await tester.pumpAndSettle();
            expect(fieldText(tester, target), isNotEmpty);
            final lastValidResult = fieldText(tester, target);
            await tester.enterText(source, invalid);
            await tester.pumpAndSettle();
            if (['12..3', 'NaN', 'Infinity'].contains(invalid)) {
              // Invalid pasted text is now rejected before reaching conversion.
              expect(fieldText(tester, source), '12');
              expect(fieldText(tester, target), lastValidResult);
            } else {
              expect(fieldText(tester, target), isEmpty, reason: invalid);
            }
            // Keep the defensive check for invalid values restored or assigned
            // programmatically, which bypass TextInputFormatter.
            final field = tester.widget<TextField>(source);
            field.controller!.text = invalid;
            field.onChanged!(invalid);
            await tester.pumpAndSettle();
            expect(fieldText(tester, target), isEmpty, reason: invalid);
            // Changing a unit must not revive the last valid result.
            final menus = find.byType(DropdownMenu<dynamic>);
            final menu = tester.widget<DropdownMenu<dynamic>>(menus.last);
            menu.onSelected!(menu.dropdownMenuEntries.last.value);
            await tester.pumpAndSettle();
            expect(fieldText(tester, target), isEmpty, reason: invalid);
            expect(tester.takeException(), isNull);
          }
          await tester.enterText(source, '2.5');
          await tester.pumpAndSettle();
          expect(fieldText(tester, target), isNotEmpty);
        }
      },
    );
  }

  testWidgets(
    'Significant figures validate, cancel, dismiss, and persist on Set',
    (tester) async {
      final settings = SettingsModel();
      await tester.pumpWidget(
        testApp(SettingsPage(calculator: const StdCalc()), settings: settings),
      );
      await tester.pumpAndSettle();
      Future<void> open() async {
        await tester.tap(find.byIcon(Icons.exposure_zero_outlined));
        await tester.pumpAndSettle();
      }

      await open();
      for (final invalid in [
        '',
        '0',
        '-1',
        '22',
        '2.5',
        'abc',
        '999999999999999999999',
      ]) {
        await tester.enterText(find.byType(TextField), invalid);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextButton>(find.widgetWithText(TextButton, 'Set'))
              .onPressed,
          isNull,
        );
        expect(settings.sigFig, 7);
        expect(tester.takeException(), isNull);
      }
      await tester.enterText(find.byType(TextField), '3');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(settings.sigFig, 7);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('sigFig'), isNull);

      await open();
      await tester.enterText(find.byType(TextField), '5');
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(settings.sigFig, 7);

      for (final valid in [1, 21]) {
        await open();
        await tester.enterText(find.byType(TextField), '$valid');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Set'));
        await tester.pumpAndSettle();
        expect(settings.sigFig, valid);
        expect(prefs.getInt('sigFig'), valid);
        final restored = SettingsModel();
        await restored.load();
        expect(restored.sigFig, valid);
      }
    },
  );

  test('Invalid persisted precision falls back to the default', () async {
    for (final invalid in [0, -1, 22]) {
      SharedPreferences.setMockInitialValues({'sigFig': invalid});
      final settings = SettingsModel();
      await settings.load();
      expect(settings.sigFig, 7);
      settings.sigFig = invalid;
      expect(settings.sigFig, 7);
    }
  });

  test(
    'First launch uses and persists the supported device language',
    () async {
      final settings = SettingsModel();
      await settings.load(defaultLanguageCode: 'it');

      expect(settings.selectedLanguageCode, 'it');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selectedLanguageCode'), 'it');
    },
  );

  test('Saved language takes precedence over the device language', () async {
    SharedPreferences.setMockInitialValues({'selectedLanguageCode': 'fr'});
    final settings = SettingsModel();
    await settings.load(defaultLanguageCode: 'it');

    expect(settings.selectedLanguageCode, 'fr');
  });

  testWidgets(
    'Calendar differences handle DST, leap years, reverse and equal dates',
    (tester) async {
      await tester.pumpWidget(testApp(const BuildDateDiff()));
      await tester.pumpAndSettle();
      expect(find.text('0 days'), findsOneWidget);
      for (final dates in [
        ['03/29/2026', '03/30/2026', '1 day'],
        ['03/30/2026', '03/29/2026', '1 day'],
        ['10/25/2026', '10/26/2026', '1 day'],
        ['02/28/2024', '03/01/2024', '2 days'],
        ['03/30/2026', '03/30/2026', '0 days'],
      ]) {
        await chooseDate(tester, 0, dates[0]);
        await chooseDate(tester, 1, dates[1]);
        expect(find.text(dates[2]), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
