import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import '../modules/Flight.dart';
import '../utilities/AppDatabase.dart';
import '../utilities/AppLocalizations.dart';

class FlightsListPage extends StatefulWidget {
  @override
  _FlightsListPageState createState() => _FlightsListPageState();
}

class _FlightsListPageState extends State<FlightsListPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _departureTimeController = TextEditingController();
  final TextEditingController _arrivalTimeController = TextEditingController();
  late AppDatabase _db;
  List<Flight> _flights = [];
  Flight? _selectedFlight;
  final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _initDb();
    _loadSavedData();
  }

  Future<void> _initDb() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _db = database;
    _loadFlights();
  }

  Future<void> _loadFlights() async {
    final data = await _db.flightDao.getAllFlights();
    setState(() {
      _flights = data;
    });
  }

  Future<void> _addFlight() async {
    final flightName = _nameController.text;
    final departureCity = _departureController.text;
    final destinationCity = _destinationController.text;
    final departureTime = _departureTimeController.text;
    final arrivalTime = _arrivalTimeController.text;

    if (flightName.isNotEmpty && departureCity.isNotEmpty && destinationCity.isNotEmpty &&
        departureTime.isNotEmpty && arrivalTime.isNotEmpty) {
      final flight = Flight(
        flightName,
        departureCity,
        destinationCity,
        departureTime,
        arrivalTime,
      );

      await _db.flightDao.insertFlight(flight);
      _loadFlights();

      _saveData();

      _nameController.clear();
      _departureController.clear();
      _destinationController.clear();
      _departureTimeController.clear();
      _arrivalTimeController.clear();

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
    if (_selectedFlight == flight) {
      setState(() {
        _selectedFlight = null;
      });
    }
  }

  Future<void> _updateFlight(int id) async {
    final flightName = _nameController.text;
    final departureCity = _departureController.text;
    final destinationCity = _destinationController.text;
    final departureTime = _departureTimeController.text;
    final arrivalTime = _arrivalTimeController.text;

    if (flightName.isNotEmpty && departureCity.isNotEmpty && destinationCity.isNotEmpty &&
        departureTime.isNotEmpty && arrivalTime.isNotEmpty) {
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

      _saveData();

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

  void _onItemTap(Flight flight) {
    setState(() {
      _selectedFlight = flight;
      _nameController.text = flight.flightName;
      _departureController.text = flight.departureCity;
      _destinationController.text = flight.destination;
      _departureTimeController.text = flight.departureTime;
      _arrivalTimeController.text = flight.arrivalTime;
    });
  }

  void _saveData() {
    _encryptedPrefs.setString('flightName', _nameController.text);
    _encryptedPrefs.setString('departureCity', _departureController.text);
    _encryptedPrefs.setString('destinationCity', _destinationController.text);
    _encryptedPrefs.setString('departureTime', _departureTimeController.text);
    _encryptedPrefs.setString('arrivalTime', _arrivalTimeController.text);
  }

  void _loadSavedData() async {
    _nameController.text = await _encryptedPrefs.getString('flightName') ?? '';
    _departureController.text = await _encryptedPrefs.getString('departureCity') ?? '';
    _destinationController.text = await _encryptedPrefs.getString('destinationCity') ?? '';
    _departureTimeController.text = await _encryptedPrefs.getString('departureTime') ?? '';
    _arrivalTimeController.text = await _encryptedPrefs.getString('arrivalTime') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(AppLocalizations.of(context)?.translate('flightsListPage') ?? 'Flights List Page'),
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)?.translate('instructions') ?? 'Instructions'),
                      content: Text(AppLocalizations.of(context)?.translate('instructionsContent') ?? 'Instructions on how to use the interface.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)?.translate('ok') ?? 'OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isLargeScreen
                ? Row(
              children: [
                Expanded(child: _buildFlightList()),
                VerticalDivider(),
                if (_selectedFlight != null)
                  Expanded(child: _buildDetailsPage(_selectedFlight!)),
              ],
            )
                : _selectedFlight == null
                ? _buildFlightList()
                : _buildDetailsPage(_selectedFlight!),
          ),
        );
      },
    );
  }

  Widget _buildFlightList() {
    return Column(
      children: <Widget>[
    Row(
    children: <Widget>[
    Expanded(
    child: TextField(
    controller: _nameController,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)?.translate('enterFlightName') ?? 'Enter flight name',
      ),
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    Row(
    children: <Widget>[
    Expanded(
    child: TextField(
    controller: _departureController,
    decoration: InputDecoration(
    labelText: AppLocalizations.of(context)?.translate('enterDepartureCity') ?? 'Enter departure city',
    ),
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    Row(
    children: <Widget>[
    Expanded(
    child: TextField(
    controller: _destinationController,
    decoration: InputDecoration(
    labelText: AppLocalizations.of(context)?.translate('enterDestinationCity') ?? 'Enter destination city',
    ),
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    Row(
    children: <Widget>[
    Expanded(
    child: TextField(
    controller: _departureTimeController,
    decoration: InputDecoration(
    labelText: AppLocalizations.of(context)?.translate('enterDepartureTime') ?? 'Enter departure time',
    ),
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    Row(
    children: <Widget>[
    Expanded(
    child: TextField(
    controller: _arrivalTimeController,
    decoration: InputDecoration(
    labelText: AppLocalizations.of(context)?.translate('enterArrivalTime') ?? 'Enter arrival time',
    ),
    ),
    ),
    ],
    ),
    SizedBox(height: 8),
    ElevatedButton(
    onPressed: _addFlight,
    child: Text(AppLocalizations.of(context)?.translate('addFlight') ?? 'Add Flight'),
    ),
    SizedBox(height: 20),
    Expanded(
    child: _flights.isEmpty
    ? Center(child: Text(AppLocalizations.of(context)?.translate('noFlights') ?? 'No Flights'))
        : ListView.builder(
      itemCount: _flights.length,
      itemBuilder: (context, index) {
        final flight = _flights[index];
        return GestureDetector(
          onTap: () => _onItemTap(flight),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${AppLocalizations.of(context)?.translate('flightNumber')} ${index + 1}: ${flight.flightName} ${AppLocalizations.of(context)?.translate('from')} ${flight.departureCity} ${AppLocalizations.of(context)?.translate('to')} ${flight.destination}',
                ),
              ],
            ),
          ),
        );
      },
    ),
    ),
      ],
    );
  }

  Widget _buildDetailsPage(Flight flight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context)?.translate('flightName')}: ${flight.flightName}',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          '${AppLocalizations.of(context)?.translate('departureCity')}: ${flight.departureCity}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          '${AppLocalizations.of(context)?.translate('destinationCity')}: ${flight.destination}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          '${AppLocalizations.of(context)?.translate('departureTime')}: ${flight.departureTime}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          '${AppLocalizations.of(context)?.translate('arrivalTime')}: ${flight.arrivalTime}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateFlight(flight.flightID!),
                child: Text(AppLocalizations.of(context)?.translate('update') ?? 'Update'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _deleteFlight(flight),
                child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

