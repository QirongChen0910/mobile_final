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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', 'US'); // Default locale

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.onLocaleChanged});

  final String title;
  final void Function(Locale) onLocaleChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        actions: [
      Padding(
      padding: const EdgeInsets.only(right: 21.0), // Adjust the value to move it left
          child: PopupMenuButton<String>(
            onSelected: _changeLanguage,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                PopupMenuItem(
                  value: 'zh',
                  child: Text('中文'),
                ),
              ];
            },
            icon: Icon(Icons.language),
                ),
            ),
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                localizations?.translate('welcomeMessage') ?? 'Welcome to our app!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Explore the different sections of our application using the buttons below.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerListPage()),
                  );
                },
                child: Text(localizations?.translate('customerListPage') ?? 'Customer List Page'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AirplaneListPage()),
                  );
                },
                child: Text(localizations?.translate('airplaneListPage') ?? 'Airplane List Page'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FlightsListPage()),
                  );
                },
                child: Text(localizations?.translate('flightsListPage') ?? 'Flights List Page'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddReservationPage()),
                  );
                },
                child: Text(localizations?.translate('reservationPage') ?? 'Reservation Page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
