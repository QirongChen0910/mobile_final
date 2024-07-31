import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:mobile_final/pages/AddReservationPage.dart';
import 'package:mobile_final/pages/AirplaneListPage.dart';
import 'package:mobile_final/pages/CustomerListPage.dart';
import 'package:mobile_final/pages/FlightsListPage.dart';
import 'package:mobile_final/utilities/AppLocalizations.dart';

void main() {
  runApp(const MyApp());
}

/// The main application widget.
///
/// This widget is the root of the application and sets up the localization, theme, and navigation.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', 'US'); // Default locale

  /// Updates the application locale.
  ///
  /// [locale] The new locale to be set.
  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('zh', 'CN'),
      ],
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Application Home Page',
        onLocaleChanged: _setLocale,
      ),
    );
  }
}

/// The home page widget.
///
/// This widget displays the main screen of the application with navigation options and language change functionality.
class MyHomePage extends StatefulWidget {
  /// Creates an instance of `MyHomePage`.
  ///
  /// [title] The title to be displayed in the app bar.
  /// [onLocaleChanged] A callback function to handle locale changes.
  const MyHomePage({super.key, required this.title, required this.onLocaleChanged});

  final String title;
  final void Function(Locale) onLocaleChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Changes the application language.
  ///
  /// [languageCode] The language code of the new locale to be set.
  void _changeLanguage(String languageCode) {
    Locale newLocale;
    if (languageCode == 'en') {
      newLocale = const Locale('en', 'US');
    } else if (languageCode == 'zh') {
      newLocale = const Locale('zh', 'CN');
    } else {
      newLocale = const Locale('en', 'US'); // Default to English
    }
    widget.onLocaleChanged(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerListPage()),
                );
              },
              child: Text(localizations?.translate('customerListPage') ?? 'Customer List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AirplaneListPage()),
                );
              },
              child: Text(localizations?.translate('airplaneListPage') ?? 'Airplane List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FlightsListPage()),
                );
              },
              child: Text(localizations?.translate('flightsListPage') ?? 'Flights List Page'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddReservationPage()),
                );
              },
              child: Text(localizations?.translate('reservationPage') ?? 'Reservation Page'),
            ),
            Text(
              localizations?.translate('welcomeMessage') ?? 'Welcome to our app!',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _changeLanguage('en'),
                  child: const Text('English'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _changeLanguage('zh'),
                  child: const Text('中文'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
