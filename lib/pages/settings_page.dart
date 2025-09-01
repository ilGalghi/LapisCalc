import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lapiscalc/l10n/app_localizations.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';


import '../models/settings_model.dart';
import '../pages/calc/standard_calc.dart';
import 'package:lapiscalc/main.dart';






class SettingsPage extends StatelessWidget {
  final StdCalc calculator;

  SettingsPage({required this.calculator, Key? key}) : super(key: key);
  final TextEditingController sigFigInput = TextEditingController();
  AndroidDeviceInfo? androidInfo; // Declare androidInfo as a nullable variable


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


  void _clearHistory(BuildContext context) {
    // Trova l'istanza del widget StdCalc nel widget tree
    StdCalc stdCalcWidget = context.findAncestorWidgetOfExactType<StdCalc>()!;

    // Chiama il metodo per cancellare la cronologia nel widget StdCalc
    stdCalcWidget.clearHistory();
  }


  //SELEZIONA LINGUA
  Future<void> _setSelectedLanguage(String languageCode, BuildContext context) async {
    final settings = Provider.of<SettingsModel>(context, listen: false);
    settings.selectedLanguageCode = languageCode;
    await settings.save();
    MyApp.setLocale(context, Locale(languageCode));
  }


  //INFORMAZIONI DISPOSITIVO
  Future<void> _initDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (!kIsWeb) {
        androidInfo = await deviceInfo.androidInfo;
      }
    } catch (e) {
      print('Failed to get device info: $e');
    }
  }

  //INFORMAZIONI APP PACCHETTO
  Future<PackageInfo> _getPackageInfo() async {
    return await PackageInfo.fromPlatform();
  }


  //MODULO INVIO EMAIL ---------------------------------------------------------
  Future<void> _sendEmail(BuildContext context) async {
    await _initDeviceInfo();
    final PackageInfo packageInfo = await _getPackageInfo();

    // Check if androidInfo is null and not on web
    if (androidInfo == null && !kIsWeb) {
      throw Exception('Android device info not available.');
    }

    String deviceInfoText = kIsWeb
        ? 'Device information not available on web platform.'
        : '''
**App info:**
   App Name: ${packageInfo.appName}
   App PackageName: ${packageInfo.packageName}
   App Version: ${packageInfo.version}
   App BuildNumber: ${packageInfo.buildNumber}
    
**Device info:**
   Manufacturer: ${androidInfo!.manufacturer}
   Brand: ${androidInfo!.brand}
   Device: ${androidInfo!.device}
   Model: ${androidInfo!.model}
   Board: ${androidInfo!.board}
   Hardware: ${androidInfo!.hardware}
   Android Host: ${androidInfo!.host}
   Display: ${androidInfo!.display}
   Device ID: ${androidInfo!.id}
   Product: ${androidInfo!.product}
   Tags: ${androidInfo!.tags}
   Type: ${androidInfo!.type}
   Supported64BitAbis': ${androidInfo!.supported64BitAbis}
   isPhysicalDevice': ${androidInfo!.isPhysicalDevice}
   isLowRamDevice': ${androidInfo!.isLowRamDevice}
   Version: ${androidInfo!.version}
   Version Base OS: ${androidInfo!.version.baseOS}
   Android Version Release: ${androidInfo!.version.release}
   Android SDK int: ${androidInfo!.version.sdkInt}''';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ilgalghi.developer@gmail.com',
      query: 'subject=SUPPORT: LapisCalc&body=\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n'
          '-------------------------------------------------------------------'
          '-------------------------------------------------------------------'
          '-------------------------------------------------------------------'
          '\nDEBUG INFO:\n$deviceInfoText'
    );

    try {
      await launchUrl(emailLaunchUri);
    } catch (e) {
      throw Exception('Could not launch debug email.');
    }

  }

  //----------------------------------------------------------------------------


  //GESTIONE WIDGET
  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(AppLocalizations.of(context)!.settings),
          ),
          SliverToBoxAdapter(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [

                //THEME --------------------------------------------------------
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: Text(AppLocalizations.of(context)!.theme),
                  onTap: () =>
                      Navigator.push(context, _createRoute(const ThemePage())),
                ),

                //SIGNIFICANT FIGURES ------------------------------------------
                ListTile(
                  leading: const Icon(Icons.exposure_zero_outlined),
                  title: Text(AppLocalizations.of(context)!.setsignificantfigures),
                  onTap: () => showDialog(
                      context: context,
                      builder: (context) {
                        sigFigInput.text = settings.sigFig.toString();
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: AlertDialog(
                            title: Text(AppLocalizations.of(context)!.setsignificantfigures,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(AppLocalizations.of(context)!.onlyforConvertors),
                                    //"This settings is exclusively for unit convertors"),
                                TextField(
                                  textAlign: TextAlign.end,
                                  keyboardType: TextInputType.number,
                                  controller: sigFigInput,
                                  onChanged: (value) => value.isNotEmpty
                                      ? settings.sigFig = int.parse(value)
                                      : settings.sigFig = 7,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(AppLocalizations.of(context)!.cancel),
                              ),
                              TextButton(
                                onPressed: () {
                                  settings.sigFig = int.parse(sigFigInput.text);
                                  Navigator.pop(context);
                                },
                                child: Text(AppLocalizations.of(context)!.set),
                              ),
                            ],
                          ),
                        );
                      }),
                ),

                /*
                // SOTTOTITOLO
                ListTile(
                  title: Text("Il tuo sottotitolo qui"),
                  dense: true,
                ),

                */

                // HISTORY
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(AppLocalizations.of(context)!.clearHistory),
                  onTap: () {
                    // Chiamata  alla funzione che cancella la cronologia
                    calculator.clearHistory();
                    Fluttertoast.showToast(
                        msg: AppLocalizations.of(context)!.clearedHistory,
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 18.0,
                        webBgColor: "#000", // Colore di sfondo per piattaforma web
                        webPosition: "center", // Posizione del toast per piattaforma web

                    );
                  },
                ),

                //LANGUAGE -----------------------------------------------------
                ListTile(

                  leading: const Icon(Icons.language),
                  title: Text(AppLocalizations.of(context)!.language),
                  subtitle: Text(AppLocalizations.of(context)!.selectedLanguage),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          AppLocalizations.of(context)!.selectlanguage,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Language options (Add your own language options)
                            ListTile(
                              title: Text("English"),
                              onTap: () async {
                                await _setSelectedLanguage('en', context);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text("Italiano"),
                              onTap: () async {
                                await _setSelectedLanguage('it', context);
                                Navigator.pop(context);

                              },
                            ),
                            ListTile(
                              title: Text("Español"),
                              onTap: () async {
                                await _setSelectedLanguage('es', context);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text("Français"),
                              onTap: () async {
                                await _setSelectedLanguage('fr', context);
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              title: Text("Română"),
                              onTap: () async {
                                await _setSelectedLanguage('ro', context);
                                Navigator.pop(context);
                              },
                            ),

                            // Add more languages as needed
                          ],
                        ),
                      );
                    },
                  ),
                ),



                // RATE REVIEW -------------------------------------------------
                ListTile(
                  leading: const Icon(Icons.star),
                  title: Text(AppLocalizations.of(context)!.leaveReview),
                    onTap: () async {
                      final InAppReview inAppReview = InAppReview.instance;
                      inAppReview.openStoreListing(appStoreId: '...', microsoftStoreId: '...');
                    }

                  // NORMALE LINK ----------------------------------------------
                  /*
                  onTap: () async {
                    const url = 'https://play.google.com/store/apps/details?id=com.ilgalghi.lapiscalc';
                      if (!await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication)) {
                        throw Exception('Could not launch $url');
                      }
                  },
                  */
                  //------------------------------------------------------------

                  /*
                  //https://pub.dev/packages/in_app_review
                  onTap: () async {

                      final InAppReview inAppReview = InAppReview.instance;
                      if (await inAppReview.isAvailable()) {
                        inAppReview.requestReview();
                      }
                  }
                   */
                  //------------------------------------------------------------
                ),


                //DONATIONS ----------------------------------------------------
                ListTile(
                  leading: const Icon(Icons.coffee),
                  title: Text(AppLocalizations.of(context)!.buyMeCoffee),
                  onTap: () async {
                    const url = 'https://www.paypal.me/ilgalghi';
                    if (!await launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                ),

                //ABOUT --------------------------------------------------------
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(AppLocalizations.of(context)!.about),
                  onTap: () =>
                      Navigator.push(context, _createRoute(const About())),
                ),

                //CONTACT ME ---------------------------------------------------
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(AppLocalizations.of(context)!.contactme),
                  onTap: () async {
                    await _sendEmail(context);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}



//TEMA -------------------------------------------------------------------------
class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  static const platform =
  MethodChannel('com.ilgalghi.lapiscalc/androidversion');

  int av = 0;
  Future<int> androidVersion() async {
    final result = await platform.invokeMethod('getAndroidVersion');
    return await result;
  }

  void fetchVersion() async {
    final v = await androidVersion();
    setState(() {
      av = v;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchVersion();
  }

  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(AppLocalizations.of(context)!.theme),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SegmentedButton(
                    segments: [
                      ButtonSegment(
                          value: ThemeMode.system, label: Text(AppLocalizations.of(context)!.system)),
                      ButtonSegment(
                          value: ThemeMode.light, label: Text(AppLocalizations.of(context)!.light)),
                      ButtonSegment(value: ThemeMode.dark, label: Text(AppLocalizations.of(context)!.dark)),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (p0) {
                      settings.themeMode = p0.first;
                    },
                  ),
                ),
                ListView(
                  shrinkWrap: true,
                  children: [
                    SwitchListTile(
                      value: settings.isSystemColor,
                      onChanged: av >= 31
                          ? (value) => settings.isSystemColor = value
                          : null,
                      title: Text(AppLocalizations.of(context)!.usesystemcolorscheme),
                      subtitle: Text(settings.isSystemColor
                          ? (AppLocalizations.of(context)!.usingsystemdynamiccolor)
                          : (AppLocalizations.of(context)!.usingdefaultcolorscheme)),
                    ),
                  ],
                )

              ],
            ),
          )
        ],
      ),
    );
  }
}
//------------------------------------------------------------------------------



//INFO (About)
//------------------------------------------------------------------------------
class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar.large(
          title: Text(AppLocalizations.of(context)!.about),
        ),
        SliverToBoxAdapter(
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text("App Version"),
                subtitle: Text("1.1.9"),          //da modificare ogni release
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("Licenses"),
                onTap: () => showLicensePage(
                    context: context,
                    applicationName: "LapisCalc",
                    applicationVersion: "1.1.9"),     //da modificare ogni release
              ),
              /*
              ListTile(
                leading: SvgPicture.asset(
                  Theme.of(context).brightness == Brightness.light
                      ? "assets/github-mark.svg"
                      : "assets/github-mark-white.svg",
                  semanticsLabel: 'Github',
                  height: 24,
                  width: 24,
                ),
                title: const Text("Github"),
                onTap: () async {
                  const url = 'https://github.com/boredcodebyk/mintcalc';
                  if (!await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication)) {
                    throw Exception('Could not launch $url');
                  }
                },
              ),
              */

            ],
          ),
        ),
      ]),
    );
  }
}

extension StringExtension on String {
  /// Capitalize the first letter of a word
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

