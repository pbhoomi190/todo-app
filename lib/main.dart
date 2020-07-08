import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertododemo/screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    print(state);
    state.setLocale(locale);
  }

  static void setTheme(BuildContext context, ThemeMode mode) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setTheme(mode);
  }
}

class _MyAppState extends State<MyApp> {
  Locale homeLocale;
  ThemeMode themeMode;

  void setTheme(ThemeMode mode) {
    setState(() {
      themeMode = mode;
      setThemeOnPreferences();
    });
  }

  void setLocale(Locale locale) {
    print(locale);
    setState(() {
      homeLocale = locale;
      setLocaleOnPreferences();
    });
  }

  Future<void> getAppData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      print("Theme := ${prefs.getBool('isDark')} and Locale := ${prefs.getString('locale')}");
      themeMode = prefs.getBool('isDark') ?? false ? ThemeMode.dark : ThemeMode.light;
      homeLocale = Locale(prefs.getString('locale') ?? "en");
    });
  }

  Future<void> setThemeOnPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', themeMode == ThemeMode.dark ? true : false);
  }

  Future<void> setLocaleOnPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', homeLocale.languageCode);
  }

  @override
  void initState() {
    getAppData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: homeLocale,

      localizationsDelegates: [
        const LocalizationManagerDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocale) {
        print('callback on locale');
        for(var locale in supportedLocale) {
          if(locale.languageCode == deviceLocale.languageCode && locale.countryCode == deviceLocale.countryCode) {
            return deviceLocale;
          }
        }
        return supportedLocale.first;
      },
      supportedLocales: [
        const Locale('en'),
        const Locale.fromSubtags(languageCode: 'hi'),
        const Locale.fromSubtags(languageCode: 'fr'),
        const Locale.fromSubtags(languageCode: 'es'),
      ],
      themeMode: themeMode,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        primaryColor: Colors.blue.shade800,
        accentColor: Colors.blue.shade200,
        fontFamily: 'Raleway',
        textTheme: ThemeData.light().textTheme.copyWith(
            bodyText1: TextStyle(
                color: Colors.brown.shade800,
                fontSize: 20,
                fontWeight: FontWeight.bold
            ),
            bodyText2: TextStyle( // Default text style for material
                color: Colors.brown.shade800,
                fontSize: 18
            ),
            headline6: TextStyle( // App bar title and Alert dialog title
                fontSize: 22.0,
                fontFamily: 'RobotoCondensed',
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade900
            )
        ),
      ),
      home: SplashScreen(),
    );
  }
}


