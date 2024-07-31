import 'package:flutter/material.dart';
import '../modules/Flight.dart';
import '../utilities/AppDatabase.dart';

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

  @override
  void initState() {
    super.initState();
    _initDb();
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

      _nameController.clear();
      _departureController.clear();
      _destinationController.clear();
      _departureTimeController.clear();
      _arrivalTimeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flight added')),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('All fields are required and must have valid values.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
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
        title: Text('Flight Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Flight Name'),
            ),
            TextField(
              controller: _departureController,
              decoration: InputDecoration(labelText: 'Departure City'),
            ),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(labelText: 'Destination City'),
            ),
            TextField(
              controller: _departureTimeController,
              decoration: InputDecoration(labelText: 'Departure Time'),
            ),
            TextField(
              controller: _arrivalTimeController,
              decoration: InputDecoration(labelText: 'Arrival Time'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateFlight(flight.flightID!);
            },
            child: Text('Update'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFlight(flight);
            },
            child: Text('Delete'),
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

      _nameController.clear();
      _departureController.clear();
      _destinationController.clear();
      _departureTimeController.clear();
      _arrivalTimeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flight updated')),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('All fields are required and must have valid values.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flights List'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Enter flight name'),
          ),
          TextField(
            controller: _departureController,
            decoration: InputDecoration(labelText: 'Enter departure city'),
          ),
          TextField(
            controller: _destinationController,
            decoration: InputDecoration(labelText: 'Enter destination city'),
          ),
          TextField(
            controller: _departureTimeController,
            decoration: InputDecoration(labelText: 'Enter departure time'),
          ),
          TextField(
            controller: _arrivalTimeController,
            decoration: InputDecoration(labelText: 'Enter arrival time'),
          ),
          ElevatedButton(
            onPressed: _addFlight,
            child: Text('Add Flight'),
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
    );
  }
}
