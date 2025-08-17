import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:lapiscalc/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './pages/pages.dart';
import 'models/settings_model.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsmodel = SettingsModel();
  settingsmodel.load();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: settingsmodel),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state =
    context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  void _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selectedLanguageCode');
    if (savedLanguage != null) {
      setLocale(Locale(savedLanguage));
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
    ));

    final defaultLightColorScheme = ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 17, 75, 243));

    final defaultDarkColorScheme = ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 17, 75, 243),
        brightness: Brightness.dark);

    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'Lapis Calc',

          // LINGUE
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: _locale,


          // TEMI
          theme: ThemeData(
            colorScheme: settings.isSystemColor
                ? lightColorScheme
                : defaultLightColorScheme,
            fontFamily: 'Manrope',
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: settings.isSystemColor
                ? darkColorScheme
                : defaultDarkColorScheme,
            fontFamily: 'Manrope',
            useMaterial3: true,
          ),
          themeMode: settings.themeMode,

          // HOME
          home: const MyHomePage(),
        );
      },
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List _pages = [
    StdCalc(),
    //SciCalc(),
    DateCalc(),
    AngleConv(),
    TemperatureConv(),
    DataConv(),
    TimeConv(),
    AreaConv(),
    LengthConv(),
    VolumeConv(),
    MassConv(),
    PressureConv(),
    SpeedConv(),
    PowerConv(),
    EnergyConv(),
    TipConv(),
  ];
  final _pageTitles = {
    StdCalc: StdCalc.pageTitle,
    //SciCalc: SciCalc.pageTitle,
    DateCalc: DateCalc.pageTitle,
    AngleConv: AngleConv.pageTitle,
    TemperatureConv: TemperatureConv.pageTitle,
    DataConv: DataConv.pageTitle,
    TimeConv: TimeConv.pageTitle,
    AreaConv: AreaConv.pageTitle,
    LengthConv: LengthConv.pageTitle,
    VolumeConv: VolumeConv.pageTitle,
    MassConv: MassConv.pageTitle,
    PressureConv: PressureConv.pageTitle,
    SpeedConv: SpeedConv.pageTitle,
    PowerConv: PowerConv.pageTitle,
    EnergyConv: EnergyConv.pageTitle,
    TipConv: TipConv.pageTitle
  };
  int selectedIndex = 0;

  Route _createRoute(Widget widget) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarText = _pageTitles[_pages[selectedIndex].runtimeType] ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarText),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.push(context, _createRoute(SettingsPage(calculator: const StdCalc()))),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: _pages.elementAt(selectedIndex),
      drawer: NavigationDrawer(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) => setState(() {
          selectedIndex = value;
          Navigator.pop(context);
        }),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              (AppLocalizations.of(context)!.calculator),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.calculate_outlined),
            selectedIcon: const Icon(Icons.calculate),
            label: Text(AppLocalizations.of(context)!.standard),
          ),

          /* SEZIONE SCIENTIFICA
          NavigationDrawerDestination(
            icon: Icon(Icons.science_outlined),
            selectedIcon: Icon(Icons.science),
            label: Text(AppLocalizations.of(context)!.scientific),
          ),
          */

          NavigationDrawerDestination(
            icon: const Icon(Icons.date_range_outlined),
            selectedIcon: const Icon(Icons.date_range),
            label: Text(AppLocalizations.of(context)!.date),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              AppLocalizations.of(context)!.converter,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.architecture),
            selectedIcon: const Icon(Icons.architecture),
            label: Text(AppLocalizations.of(context)!.angle),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.thermostat),
            selectedIcon: const Icon(Icons.thermostat),
            label: Text(AppLocalizations.of(context)!.temperature),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.sd_card_outlined),
            selectedIcon: const Icon(Icons.sd_card),
            label: Text(AppLocalizations.of(context)!.data),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.watch_later_outlined),
            selectedIcon: const Icon(Icons.watch_later),
            label: Text(AppLocalizations.of(context)!.time),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.crop),
            selectedIcon: const Icon(Icons.crop),
            label: Text(AppLocalizations.of(context)!.area),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.straighten),
            selectedIcon: const Icon(Icons.straighten),
            label: Text(AppLocalizations.of(context)!.length),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.free_breakfast_outlined),
            selectedIcon: const Icon(Icons.free_breakfast),
            label: Text(AppLocalizations.of(context)!.volume),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.scale_outlined),
            selectedIcon: const Icon(Icons.scale),
            label: Text(AppLocalizations.of(context)!.mass),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.speed),
            selectedIcon: const Icon(Icons.speed),
            label: Text(AppLocalizations.of(context)!.pressure),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.run_circle_outlined),
            selectedIcon: const Icon(Icons.run_circle),
            label: Text(AppLocalizations.of(context)!.speed),
          ),

          //Power
          NavigationDrawerDestination(
            icon: const Icon(Icons.power_outlined),
            selectedIcon: const Icon(Icons.power_rounded),
            label: Text(AppLocalizations.of(context)!.power),
          ),

          //Energy
          NavigationDrawerDestination(
            icon: const Icon(Icons.electric_bolt_rounded),
            selectedIcon: const Icon(Icons.electric_bolt_outlined),
            label: Text(AppLocalizations.of(context)!.energy),
          ),

          //Tip
          NavigationDrawerDestination(
            icon: const Icon(Icons.monetization_on_outlined),
            selectedIcon: const Icon(Icons.monetization_on),
            label: Text(AppLocalizations.of(context)!.tip),
          ),


        ],
      ),
    );
  }
}
