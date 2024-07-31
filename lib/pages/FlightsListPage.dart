import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import '../modules/Flight.dart';
import '../utilities/AppDatabase.dart';
import '../utilities/AppLocalizations.dart';

class FlightsListPage extends StatefulWidget {
  @override
  _FlightsListPageState createState() => _FlightsListPageState();
}

class _FlightsListPageState extends State<FlightsListPage> {
  final List<Flight> _flights = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _departureTimeController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  late AppDatabase _db;
  late EncryptedSharedPreferences _encryptedSharedPreferences;

  @override
  void initState() {
    super.initState();
    _initDb();
    _initEncryptedSharedPreferences();
  }

  Future<void> _initDb() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _db = database;
    _loadFlights();
  }

  Future<void> _initEncryptedSharedPreferences() async {
    _encryptedSharedPreferences = EncryptedSharedPreferences();
  }

  Future<void> _loadFlights() async {
    final data = await _db.flightDao.getAllFlights();
    setState(() {
      _flights.clear();
      _flights.addAll(data);
    });
  }

  Future<void> _addFlight() async {
    final flightName = _nameController.text;
    final departureCity = _departureController.text;
    final destinationCity = _destinationController.text;
    final departureTime = _departureTimeController.text;
    final arrivalTime = _arrivalTimeController.text;

    if (flightName.isNotEmpty &&
        departureCity.isNotEmpty &&
        destinationCity.isNotEmpty &&
        departureTime.isNotEmpty &&
        arrivalTime.isNotEmpty) {
      final flight = Flight(
        flightName,
        departureCity,
        destinationCity,
        departureTime,
        arrivalTime,
      );

      await _db.flightDao.insertFlight(flight);
      _loadFlights();

      _nameController.clear();
      _departureController.clear();
      _destinationController.clear();
      _departureTimeController.clear();
      _arrivalTimeController.clear();

      await _encryptedSharedPreferences.setString('lastFlightName', flightName);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.translate('flightAdded') ?? 'Flight added')),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error'),
          content: Text(AppLocalizations.of(context)?.translate('allFieldsRequired') ?? 'All fields are required and must have valid values.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.translate('ok') ?? 'OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _deleteFlight(Flight flight) async {
    await _db.flightDao.deleteFlight(flight);
    _loadFlights();
  }

  void _showFlightDetails(Flight flight) {
    _nameController.text = flight.flightName;
    _departureController.text = flight.departureCity;
    _destinationController.text = flight.destination;
    _departureTimeController.text = flight.departureTime;
    _arrivalTimeController.text = flight.arrivalTime;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('flightDetails') ?? 'Flight Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('flightName') ?? 'Flight Name'),
            ),
            TextField(
              controller: _departureController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('departureCity') ?? 'Departure City'),
            ),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('destinationCity') ?? 'Destination City'),
            ),
            TextField(
              controller: _departureTimeController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('departureTime') ?? 'Departure Time'),
            ),
            TextField(
              controller: _arrivalTimeController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('arrivalTime') ?? 'Arrival Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateFlight(flight.flightID!);
            },
            child: Text(AppLocalizations.of(context)?.translate('update') ?? 'Update'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFlight(flight);
            },
            child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateFlight(int id) async {
    final flightName = _nameController.text;
    final departureCity = _departureController.text;
    final destinationCity = _destinationController.text;
    final departureTime = _departureTimeController.text;
    final arrivalTime = _arrivalTimeController.text;

    if (flightName.isNotEmpty &&
        departureCity.isNotEmpty &&
        destinationCity.isNotEmpty &&
        departureTime.isNotEmpty &&
        arrivalTime.isNotEmpty) {
      final flight = Flight(
        flightID: id,
        flightName,
        departureCity,
        destinationCity,
        departureTime,
        arrivalTime,
      );

      await _db.flightDao.updateFlight(flight);
      _loadFlights();

      _nameController.clear();
      _departureController.clear();
      _destinationController.clear();
      _departureTimeController.clear();
      _arrivalTimeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.translate('flightUpdated') ?? 'Flight updated')),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error'),
          content: Text(AppLocalizations.of(context)?.translate('allFieldsRequired') ?? 'All fields are required and must have valid values.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.translate('ok') ?? 'OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('instructions') ?? 'Instructions'),
        content: Text(AppLocalizations.of(context)?.translate('instructionsContent') ?? 'Instructions for using the app go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.translate('ok') ?? 'OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)?.translate('flightsListPage') ?? 'Flights List Page'),
          actions: [
            IconButton(
              icon: Icon(Icons.info),
              onPressed: _showInstructions,
            ),
          ],
        ),
        body: Padding(
        padding: const EdgeInsets.all(8.0),
    child: Column(
    children: <Widget>[
    TextField(
    controller: _nameController,
    decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('enterFlightName') ?? 'Enter flight name'),
    ),
    TextField(
    controller: _departureController,
      decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('enterDepartureCity') ?? 'Enter departure city'),
    ),
      TextField(
        controller: _destinationController,
        decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('enterDestinationCity') ?? 'Enter destination city'),
      ),
      TextField(
        controller: _departureTimeController,
        decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('enterDepartureTime') ?? 'Enter departure time'),
      ),
      TextField(
        controller: _arrivalTimeController,
        decoration: InputDecoration(labelText: AppLocalizations.of(context)?.translate('enterArrivalTime') ?? 'Enter arrival time'),
      ),
      ElevatedButton(
        onPressed: _addFlight,
        child: Text(AppLocalizations.of(context)?.translate('addFlight') ?? 'Add Flight'),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: _flights.length,
          itemBuilder: (context, index) {
            final flight = _flights[index];
            return ListTile(
              title: Text(flight.flightName),
              subtitle: Text('${flight.departureCity} to ${flight.destination}'),
              onTap: () => _showFlightDetails(flight),
            );
          },
        ),
      ),
    ],
    ),
        ),
    );
  }
}

