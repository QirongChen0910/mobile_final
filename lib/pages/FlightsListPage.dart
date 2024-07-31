import 'package:flutter/material.dart';
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
  final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();
  late AppDatabase _db;
  Flight? _selectedFlight;

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
      _clearFields();
      _showSnackbar(AppLocalizations.of(context)?.translate('flightAdded') ?? 'Flight added');
      _saveData();
    } else {
      _showAlertDialog(
          AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error',
          AppLocalizations.of(context)?.translate('allFieldsRequired') ?? 'All fields are required and must have valid values.');
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
      _clearFields();
      _showSnackbar(AppLocalizations.of(context)?.translate('flightUpdated') ?? 'Flight updated');
      _saveData();
    } else {
      _showAlertDialog(
          AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error',
          AppLocalizations.of(context)?.translate('allFieldsRequired') ?? 'All fields are required and must have valid values.');
    }
  }

  Future<void> _deleteFlight(Flight flight) async {
    await _db.flightDao.deleteFlight(flight);
    _loadFlights();
    _showSnackbar(AppLocalizations.of(context)?.translate('flightDeleted') ?? 'Flight deleted');
  }

  void _clearFields() {
    _nameController.clear();
    _departureController.clear();
    _destinationController.clear();
    _departureTimeController.clear();
    _arrivalTimeController.clear();
  }

  void _saveData() {
    _encryptedPrefs.setString("flightName", _nameController.text);
    _encryptedPrefs.setString("departureCity", _departureController.text);
    _encryptedPrefs.setString("destinationCity", _destinationController.text);
    _encryptedPrefs.setString("departureTime", _departureTimeController.text);
    _encryptedPrefs.setString("arrivalTime", _arrivalTimeController.text);
  }

  void _loadSavedData() async {
    final flightName = await _encryptedPrefs.getString("flightName");
    final departureCity = await _encryptedPrefs.getString("departureCity");
    final destinationCity = await _encryptedPrefs.getString("destinationCity");
    final departureTime = await _encryptedPrefs.getString("departureTime");
    final arrivalTime = await _encryptedPrefs.getString("arrivalTime");

    setState(() {
      _nameController.text = flightName ?? '';
      _departureController.text = departureCity ?? '';
      _destinationController.text = destinationCity ?? '';
      _departureTimeController.text = departureTime ?? '';
      _arrivalTimeController.text = arrivalTime ?? '';
    });
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.translate('ok') ?? 'OK'),
          ),
        ],
      ),
    );
  }

  void _onItemTap(Flight flight) {
    setState(() {
      _selectedFlight = flight;
    });
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
                icon: Icon(Icons.info),
                onPressed: () {
                  _showAlertDialog(
                    AppLocalizations.of(context)?.translate('instructions') ?? 'Instructions',
                    AppLocalizations.of(context)?.translate('instructionsMessage') ?? 'This is how you use the interface...',
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
        SizedBox(height: 20),
        Expanded(
          child: _flights.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)?.translate('noFlights') ?? 'There are no flights in the list'))
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
                      Text(flight.flightName),
                      Text('${flight.departureCity} to ${flight.destination}'),
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
      Text(
      '${AppLocalizations.of(context)?.translate('flightName') ?? 'Flight Name'}: ${flight.flightName}',
      style: TextStyle(fontSize: 20),
    ),
    Text(
      '${AppLocalizations.of(context)?.translate('departureCity') ?? 'Departure City'}: ${flight.departureCity}',
      style: TextStyle(fontSize: 16),
    ),
            Text(
              '${AppLocalizations.of(context)?.translate('destinationCity') ?? 'Destination City'}: ${flight.destination}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '${AppLocalizations.of(context)?.translate('departureTime') ?? 'Departure Time'}: ${flight.departureTime}',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '${AppLocalizations.of(context)?.translate('arrivalTime') ?? 'Arrival Time'}: ${flight.arrivalTime}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _updateFlight(flight.flightID!),
              child: Text(AppLocalizations.of(context)?.translate('update') ?? 'Update'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _deleteFlight(flight),
              child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
            ),
          ],
      ),
    );
  }
}
