import 'package:flutter/material.dart';
import '../modules/Airplane.dart';
import '../utilities/AppDatabase.dart';

class AirplaneListPage extends StatefulWidget {
  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  final List<Airplane> _airplanes = [];
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();
  final TextEditingController _rangeController = TextEditingController();
  late AppDatabase _db;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database2.db').build();
    _db = database;
    await _loadAirplanes();  // Load airplanes after database initialization
  }

  Future<void> _loadAirplanes() async {
    final data = await _db.airplaneDAO.getAllAirplanes();
    setState(() {
      _airplanes.clear();
      _airplanes.addAll(data);
    });
  }

  Future<void> _addAirplane() async {
    final type = _typeController.text;
    final passengers = int.tryParse(_passengersController.text);
    final speed = int.tryParse(_speedController.text);
    final range = int.tryParse(_rangeController.text);

    if (type.isNotEmpty && passengers != null && speed != null && range != null) {
      final airplane = Airplane(type, passengers, speed, range);
      await _db.airplaneDAO.insertAirplane(airplane);
      await _loadAirplanes();

      _typeController.clear();
      _passengersController.clear();
      _speedController.clear();
      _rangeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Airplane added')),
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

  Future<void> _deleteAirplane(Airplane airplane) async {
    await _db.airplaneDAO.deleteAirplane(airplane);
    await _loadAirplanes();
  }

  void _showAirplaneDetails(Airplane airplane) {
    _typeController.text = airplane.type;
    _passengersController.text = airplane.passengers.toString();
    _speedController.text = airplane.speed.toString();
    _rangeController.text = airplane.range.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Airplane Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: _passengersController,
              decoration: InputDecoration(labelText: 'Passengers'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _speedController,
              decoration: InputDecoration(labelText: 'Speed'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _rangeController,
              decoration: InputDecoration(labelText: 'Range'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateAirplane(airplane.id!);
            },
            child: Text('Update'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAirplane(airplane);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateAirplane(int id) async {
    final type = _typeController.text;
    final passengers = int.tryParse(_passengersController.text);
    final speed = int.tryParse(_speedController.text);
    final range = int.tryParse(_rangeController.text);

    if (type.isNotEmpty && passengers != null && speed != null && range != null) {
      final airplane = Airplane(type, passengers, speed, range, id: id);
      await _db.airplaneDAO.updateAirplane(airplane);
      await _loadAirplanes();

      _typeController.clear();
      _passengersController.clear();
      _speedController.clear();
      _rangeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Airplane updated')),
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
        title: Text('Airplanes List'),
      ),
      body: Column(
        children: <Widget>[
          TextField(
            controller: _typeController,
            decoration: InputDecoration(labelText: 'Enter airplane type'),
          ),
          TextField(
            controller: _passengersController,
            decoration: InputDecoration(labelText: 'Enter number of passengers'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _speedController,
            decoration: InputDecoration(labelText: 'Enter maximum speed'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _rangeController,
            decoration: InputDecoration(labelText: 'Enter range'),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: _addAirplane,
            child: Text('Add Airplane'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _airplanes.length,
              itemBuilder: (context, index) {
                final airplane = _airplanes[index];
                return ListTile(
                  title: Text(airplane.type),
                  subtitle: Text('Passengers: ${airplane.passengers}, Speed: ${airplane.speed}, Range: ${airplane.range}'),
                  onTap: () => _showAirplaneDetails(airplane),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
