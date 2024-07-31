import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import '../modules/Airplane.dart';
import '../utilities/AppDatabase.dart';
import 'package:mobile_final/utilities/AppLocalizations.dart';

class AirplaneListPage extends StatefulWidget {
  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();
  final TextEditingController _rangeController = TextEditingController();
  late AppDatabase _db;
  List<Airplane> _airplanes = [];
  Airplane? _selectedAirplane;
  final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _initDb();
    _loadSavedData();
  }

  Future<void> _initDb() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database2.db').build();
    _db = database;
    _loadAirplanes();
  }

  Future<void> _loadAirplanes() async {
    final data = await _db.airplaneDAO.getAllAirplanes();
    setState(() {
      _airplanes = data;
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
      _loadAirplanes();

      _saveData();

      _typeController.clear();
      _passengersController.clear();
      _speedController.clear();
      _rangeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.translate('airplaneAdded') ?? 'Airplane added')),
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

  Future<void> _deleteAirplane(Airplane airplane) async {
    await _db.airplaneDAO.deleteAirplane(airplane);
    _loadAirplanes();
    if (_selectedAirplane == airplane) {
      setState(() {
        _selectedAirplane = null;
      });
    }
  }

  Future<void> _updateAirplane(int id) async {
    final type = _typeController.text;
    final passengers = int.tryParse(_passengersController.text);
    final speed = int.tryParse(_speedController.text);
    final range = int.tryParse(_rangeController.text);

    if (type.isNotEmpty && passengers != null && speed != null && range != null) {
      final airplane = Airplane(type, passengers, speed, range, id: id);
      await _db.airplaneDAO.updateAirplane(airplane);
      _loadAirplanes();

      _saveData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.translate('airplaneUpdated') ?? 'Airplane updated')),
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

  void _onItemTap(Airplane airplane) {
    setState(() {
      _selectedAirplane = airplane;
      _typeController.text = airplane.type;
      _passengersController.text = airplane.passengers.toString();
      _speedController.text = airplane.speed.toString();
      _rangeController.text = airplane.range.toString();
    });
  }

  void _saveData() {
    _encryptedPrefs.setString('type', _typeController.text);
    _encryptedPrefs.setString('passengers', _passengersController.text);
    _encryptedPrefs.setString('speed', _speedController.text);
    _encryptedPrefs.setString('range', _rangeController.text);
  }

  void _loadSavedData() async {
    _typeController.text = await _encryptedPrefs.getString('type') ?? '';
    _passengersController.text = await _encryptedPrefs.getString('passengers') ?? '';
    _speedController.text = await _encryptedPrefs.getString('speed') ?? '';
    _rangeController.text = await _encryptedPrefs.getString('range') ?? '';
  }

  void _clearInputFields() {
    _typeController.clear();
    _passengersController.clear();
    _speedController.clear();
    _rangeController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.translate('fieldsCleared') ?? 'Input fields cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(AppLocalizations.of(context)?.translate('airplaneListPage') ?? 'Airplanes List'),
            actions: [
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)?.translate('instructions') ?? 'Instructions'),
                      content: Text(
                          AppLocalizations.of(context)?.translate('instructionsContent') ??
                              '1. To add an airplane, enter all airplane details in the input fields and then click the "Add Airplane" button to save the airplane.\n\n'
                                  '2. To view the airplane list, the list of airplanes will display below the input fields. Tap on an airplane to view its details.\n\n'
                                  '3. To update an airplane, tap on an airplane in the list to load its details, modify the details in the input fields, and click the "Update" button to save changes.\n\n'
                                  '4. To delete an airplane, tap on an airplane in the list to view its details, click the "Delete" button, and confirm the deletion in the AlertDialog.'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)?.translate('ok') ?? 'OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)?.translate('help') ?? 'Help'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: isLargeScreen
                ? Row(
              children: [
                Expanded(child: _buildAirplaneList()),
                VerticalDivider(),
                if (_selectedAirplane != null)
                  Expanded(child: _buildDetailsPage(_selectedAirplane!)),
              ],
            )
                : _selectedAirplane == null
                ? _buildAirplaneList()
                : _buildDetailsPage(_selectedAirplane!),
          ),
        );
      },
    );
  }

  Widget _buildAirplaneList() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.translate('enter_airplane_type') ?? 'Enter airplane type',
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
                controller: _passengersController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.translate('enter_number_of_passengers') ?? 'Enter number of passengers',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _speedController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.translate('enter_maximum_speed') ?? 'Enter maximum speed',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _rangeController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)?.translate('enter_range') ?? 'Enter range',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _addAirplane,
                child: Text(AppLocalizations.of(context)?.translate('add_airplane') ?? 'Add Airplane'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: _clearInputFields,
                child: Text(AppLocalizations.of(context)?.translate('clear') ?? 'Clear'),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: _airplanes.isEmpty
              ? Center(child: Text(AppLocalizations.of(context)?.translate('no_airplanes') ?? 'No Airplanes'))
              : ListView.builder(
            itemCount: _airplanes.length,
            itemBuilder: (context, index) {
              final airplane = _airplanes[index];
              return GestureDetector(
                onTap: () => _onItemTap(airplane),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${AppLocalizations.of(context)?.translate('airplane')} ${index + 1}: ${airplane.type} ${AppLocalizations.of(context)?.translate('with')} ${airplane.passengers} ${AppLocalizations.of(context)?.translate('passengers')}, ${AppLocalizations.of(context)?.translate('speed')}: ${airplane.speed} km/h, ${AppLocalizations.of(context)?.translate('range')}: ${airplane.range} km',
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

  Widget _buildDetailsPage(Airplane airplane) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context)?.translate('type')}: ${airplane.type}',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 18),
        Text(
          '${AppLocalizations.of(context)?.translate('passengers')}: ${airplane.passengers}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 18),
        Text(
          '${AppLocalizations.of(context)?.translate('speed')}: ${airplane.speed}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 18),
        Text(
          '${AppLocalizations.of(context)?.translate('range')}: ${airplane.range}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _updateAirplane(airplane.id!),
                child: Text(AppLocalizations.of(context)?.translate('update') ?? 'Update'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _deleteAirplane(airplane),
                child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
