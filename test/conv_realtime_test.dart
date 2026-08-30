import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:units_converter/units_converter.dart';
import 'package:lapiscalc/models/settings_model.dart';
import 'package:lapiscalc/pages/conv/angle_conv.dart';
import 'package:lapiscalc/pages/conv/area_conv.dart';
import 'package:lapiscalc/pages/conv/data_conv.dart';
import 'package:lapiscalc/pages/conv/energy_conv.dart';
import 'package:lapiscalc/pages/conv/length_conv.dart';
import 'package:lapiscalc/pages/conv/mass_conv.dart';
import 'package:lapiscalc/pages/conv/power_conv.dart';
import 'package:lapiscalc/pages/conv/pressure_conv.dart';
import 'package:lapiscalc/pages/conv/speed_conv.dart';
import 'package:lapiscalc/pages/conv/temp_conv.dart';
import 'package:lapiscalc/pages/conv/time_conv.dart';
import 'package:lapiscalc/pages/conv/volume_conv.dart';
import 'package:lapiscalc/pages/calc/standard_calc.dart';
import 'package:lapiscalc/pages/settings_page.dart';
import 'package:lapiscalc/l10n/app_localizations.dart';

Widget createTestWidget(Widget child, {ThemeMode themeMode = ThemeMode.system}) {
  final settings = SettingsModel();
  settings.themeMode = themeMode;
  return ChangeNotifierProvider<SettingsModel>.value(
    value: settings,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark)),
      themeMode: themeMode,
      home: child,
    ),
  );
}

Finder findInputFields() {
  return find.byWidgetPredicate((w) => w is TextField && w.textAlign == TextAlign.right);
}

void selectDropdownUnit(WidgetTester tester, Finder dropdownFinder, dynamic unit) {
  final dropdown = tester.widget<DropdownMenu<dynamic>>(dropdownFinder);
  dropdown.onSelected?.call(unit);
}

void main() {
  testWidgets('Angle converter recalculates in real-time when dropdown changes (User exact scenario: 10 deg -> seconds -> minutes)',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const AngleConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    // 1. Set dropdown A = degree, dropdown B = seconds
    selectDropdownUnit(tester, dropdownMenus.first, ANGLE.degree);
    selectDropdownUnit(tester, dropdownMenus.last, ANGLE.seconds);
    await tester.pumpAndSettle();

    // 2. Tap '1' then '0' on keypad -> 10 degrees
    await tester.tap(find.widgetWithText(FilledButton, '1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();

    // Check: 10 degrees = 36000 seconds
    final inputFields = findInputFields();
    expect(inputFields, findsNWidgets(2));

    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '10');
    expect(fieldB.controller?.text, '36000');

    // 3. Change dropdown B from seconds to minutes (WITHOUT changing inputA)
    selectDropdownUnit(tester, dropdownMenus.last, ANGLE.minutes);
    await tester.pumpAndSettle();

    // Verify inputB immediately updated to '600' (10 degrees = 600 minutes)
    fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldB.controller?.text, '600');
  });

  testWidgets('Length converter recalculates in real-time when dropdown changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const LengthConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, LENGTH.meters);
    selectDropdownUnit(tester, dropdownMenus.last, LENGTH.centimeters);
    await tester.pumpAndSettle();

    // Tap '5' on keypad
    await tester.tap(find.widgetWithText(FilledButton, '5'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '5');
    expect(fieldB.controller?.text, '500'); // 5 meters = 500 centimeters

    // Change dropdown B to millimeters
    selectDropdownUnit(tester, dropdownMenus.last, LENGTH.millimeters);
    await tester.pumpAndSettle();

    fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldB.controller?.text, '5000'); // 5 meters = 5000 millimeters
  });

  testWidgets('Temperature converter recalculates with sign toggle and dropdown change',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const TemperatureConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, TEMPERATURE.celsius);
    selectDropdownUnit(tester, dropdownMenus.last, TEMPERATURE.kelvin);
    await tester.pumpAndSettle();

    // Tap '1', '0', '0' -> 100 C
    await tester.tap(find.widgetWithText(FilledButton, '1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '100');
    expect(fieldB.controller?.text, '373.15'); // 100 C = 373.15 K

    // Tap ± button
    await tester.tap(find.text('\u00b1'));
    await tester.pumpAndSettle();

    fieldA = tester.widget<TextField>(inputFields.first);
    fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '-100');
    expect(fieldB.controller?.text, '173.15'); // -100 C = 173.15 K

    // Change dropdown B to Fahrenheit
    selectDropdownUnit(tester, dropdownMenus.last, TEMPERATURE.fahrenheit);
    await tester.pumpAndSettle();

    fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldB.controller?.text, '-148'); // -100 C = -148 F
  });

  testWidgets('Mass converter recalculates in real-time when dropdown changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const MassConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, MASS.kilograms);
    selectDropdownUnit(tester, dropdownMenus.last, MASS.grams);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '2'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '2');
    expect(fieldB.controller?.text, '2000'); // 2 kilograms = 2000 grams

    selectDropdownUnit(tester, dropdownMenus.last, MASS.milligrams);
    await tester.pumpAndSettle();

    fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldB.controller?.text, '2000000');
  });

  testWidgets('Volume converter recalculates in real-time when dropdown changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const VolumeConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, VOLUME.liters);
    selectDropdownUnit(tester, dropdownMenus.last, VOLUME.milliliters);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '3'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '3');
    expect(fieldB.controller?.text, '3000'); // 3 liters = 3000 milliliters

    selectDropdownUnit(tester, dropdownMenus.last, VOLUME.centiliters);
    await tester.pumpAndSettle();

    fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldB.controller?.text, '300'); // 3 liters = 300 centiliters
  });

  testWidgets('Time converter recalculates in real-time when dropdown changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const TimeConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, TIME.minutes);
    selectDropdownUnit(tester, dropdownMenus.last, TIME.seconds);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '6'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '60');
    expect(fieldB.controller?.text, '3600'); // 60 minutes = 3600 seconds

    selectDropdownUnit(tester, dropdownMenus.last, TIME.hours);
    await tester.pumpAndSettle();

    fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldB.controller?.text, '1'); // 60 minutes = 1 hour
  });

  testWidgets('Area converter smoke test and real-time conversion',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const AreaConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, AREA.squareMeters);
    selectDropdownUnit(tester, dropdownMenus.last, AREA.squareKilometers);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '1'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '1');
    expect(fieldB.controller?.text, '0.000001');
  });

  testWidgets('Data converter real-time conversion', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const DataConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, DIGITAL_DATA.megabyte);
    selectDropdownUnit(tester, dropdownMenus.last, DIGITAL_DATA.kilobyte);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '2'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '2');
    expect(fieldB.controller?.text, '2000');
  });

  testWidgets('Energy converter real-time conversion', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const EnergyConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, ENERGY.calories);
    selectDropdownUnit(tester, dropdownMenus.last, ENERGY.joules);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '4'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '4');
    expect(fieldB.controller?.text, '16.7472');
  });

  testWidgets('Power converter real-time conversion', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const PowerConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, POWER.kilowatt);
    selectDropdownUnit(tester, dropdownMenus.last, POWER.watt);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '3'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '3');
    expect(fieldB.controller?.text, '3000');
  });

  testWidgets('Pressure converter real-time conversion', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const PressureConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, PRESSURE.bar);
    selectDropdownUnit(tester, dropdownMenus.last, PRESSURE.pascal);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '1'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '1');
    expect(fieldB.controller?.text, '100000');
  });

  testWidgets('Speed converter real-time conversion', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const SpeedConv()));
    await tester.pumpAndSettle();

    final dropdownMenus = find.byType(DropdownMenu<dynamic>);
    selectDropdownUnit(tester, dropdownMenus.first, SPEED.kilometersPerHour);
    selectDropdownUnit(tester, dropdownMenus.last, SPEED.metersPerSecond);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '3'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '6'));
    await tester.pumpAndSettle();

    final inputFields = findInputFields();
    TextField fieldA = tester.widget<TextField>(inputFields.first);
    TextField fieldB = tester.widget<TextField>(inputFields.last);
    expect(fieldA.controller?.text, '36');
    expect(fieldB.controller?.text, '10'); // 36 km/h = 10 m/s
  });

  testWidgets('Standard calculator evaluates expressions and handles invalid syntax gracefully',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const StdCalc()));
    await tester.pumpAndSettle();

    // 5 + 3 = 8
    await tester.tap(find.widgetWithText(FilledButton, '5'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '3'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pumpAndSettle();

    final inputField = find.byType(TextField);
    TextField tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '8');

    // Incomplete syntax like "8 +" followed by "=" should show Syntax Error without unhandled exception
    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pumpAndSettle();

    expect(find.text('Syntax Error'), findsOneWidget);
  });

  testWidgets('Standard calculator calculates percentage 9%60 = 5.4 cleanly and displays % symbol',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const StdCalc()));
    await tester.pumpAndSettle();

    // 9 % 60 = 5.4
    await tester.tap(find.widgetWithText(FilledButton, '9'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '%'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '6'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();

    final inputField = find.byType(TextField);
    TextField tf = tester.widget<TextField>(inputField);
    // Verify that the input displays '9%60' instead of '9/100*60'
    expect(tf.controller?.text, '9%60');

    // Press =
    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pumpAndSettle();

    tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '5.4');

    // Test 50% = 0.5
    await tester.tap(find.widgetWithText(FilledButton, 'C'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '5'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '%'));
    await tester.pumpAndSettle();

    tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '50%');

    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pumpAndSettle();

    tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '0.5');

    // Test 10 - 20% = 8
    await tester.tap(find.widgetWithText(FilledButton, 'C'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '\u2013'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '2'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '%'));
    await tester.pumpAndSettle();

    tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '10-20%');

    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pumpAndSettle();

    tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '8');

    // Test 10 + 20% = 12
    await tester.tap(find.widgetWithText(FilledButton, 'C'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '1'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '2'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '0'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '%'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pumpAndSettle();

    tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '12');
  });

  testWidgets('Standard calculator smart parentheses behavior (open/close and auto-close on =)',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const StdCalc()));
    await tester.pumpAndSettle();

    // 1. Press () on empty -> '('
    await tester.tap(find.widgetWithText(FilledButton, '()'));
    await tester.pumpAndSettle();

    final inputField = find.byType(TextField);
    TextField tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '(');

    // 2. Press 8 + 2
    await tester.tap(find.widgetWithText(FilledButton, '8'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '2'));
    await tester.pumpAndSettle();

    // 3. Press () -> automatically closes with ')' -> '(8+2)'
    await tester.tap(find.widgetWithText(FilledButton, '()'));
    await tester.pumpAndSettle();
    tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '(8+2)');

    // 4. Press \u00d7 3 = -> '(8+2)*3' = 30
    await tester.tap(find.widgetWithText(FilledButton, '\u00d7'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '3'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pumpAndSettle();

    tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '30');

    // 5. Test auto-close when unclosed: C -> () -> 5 + 3 -> = -> 8
    await tester.tap(find.widgetWithText(FilledButton, 'C'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '()'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '5'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '+'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '3'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '='));
    await tester.pumpAndSettle();

    tf = tester.widget<TextField>(inputField);
    expect(tf.controller?.text, '8');
  });

  testWidgets('SettingsPage to About navigation in Dark Mode uses transparent transition without white flash',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(SettingsPage(calculator: const StdCalc()), themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();

    // Find and tap About (or Info) in settings
    final aboutTile = find.widgetWithText(ListTile, 'About');
    expect(aboutTile, findsOneWidget);

    await tester.ensureVisible(aboutTile);
    await tester.pumpAndSettle();

    await tester.tap(aboutTile);
    // Pump frames during transition to check SharedAxisTransition
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final transitionFinder = find.byType(SharedAxisTransition);
    expect(transitionFinder, findsWidgets);

    final SharedAxisTransition transition = tester.widget<SharedAxisTransition>(transitionFinder.first);
    // Confirm fillColor is transparent so it does not flash white in dark mode
    expect(transition.fillColor, Colors.transparent);

    await tester.pumpAndSettle();
    expect(find.text('App Version'), findsOneWidget);
  });
}




