import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../modules/Airplane.dart';
import '../DAO/AirplaneDAO.dart';
import '../utilities/AppDatabase.dart';

class AirplaneListPage extends StatefulWidget {
  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _passengersController = TextEditingController();
  final TextEditingController _speedController = TextEditingController();
  final TextEditingController _rangeController = TextEditingController();
  List<Airplane> _airplanes = [];
  Airplane? _selectedAirplane;
  final String _key = 'YOUR_ENCRYPTION_KEY'; // Make sure to use a 32-byte key
  late AppDatabase _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _loadTextField();
  }

  Future<void> _initDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _database = database;
    _loadAirplanes();
  }

  Future<void> _loadAirplanes() async {
    final airplanes = await _database.airplaneDAO.getAllAirplanes();
    setState(() {
      _airplanes = airplanes;
    });
  }

  Future<void> _addAirplane(String type, int passengers, int speed, int range) async {
    final airplane = Airplane(type, passengers, speed, range);
    await _database.airplaneDAO.insertAirplane(airplane);
    _loadAirplanes();
  }

  Future<void> _updateAirplane(Airplane airplane) async {
    await _database.airplaneDAO.updateAirplane(airplane);
    _loadAirplanes();
  }

  Future<void> _deleteAirplane(Airplane airplane) async {
    await _database.airplaneDAO.deleteAirplane(airplane);
    _loadAirplanes();
  }

  Future<void> _saveTextField(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedText = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(_key)))
        .encrypt(text, iv: encrypt.IV.fromLength(16));
    prefs.setString('airplane_text', encryptedText.base64);
  }

  Future<void> _loadTextField() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedText = prefs.getString('airplane_text') ?? '';
    if (encryptedText.isNotEmpty) {
      final decryptedText = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(_key)))
          .decrypt64(encryptedText, iv: encrypt.IV.fromLength(16));
      _typeController.text = decryptedText;
    }
  }

  void _showSnackbar(BuildContext buildContext, String message) {
    ScaffoldMessenger.of(buildContext).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAlertDialog(BuildContext buildContext, String title, String message) {
    showDialog(
      context: buildContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _typeController.clear();
    _passengersController.clear();
    _speedController.clear();
    _rangeController.clear();
    setState(() {
      _selectedAirplane = null;
    });
  }

  void _copyPreviousData() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedText = prefs.getString('airplane_text') ?? '';
    if (encryptedText.isNotEmpty) {
      final decryptedText = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(_key)))
          .decrypt64(encryptedText, iv: encrypt.IV.fromLength(16));
      _typeController.text = decryptedText;
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Airplanes'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showAlertDialog(buildContext, 'Instructions', 'Instructions on how to use the interface.');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _typeController,
              decoration: InputDecoration(
                labelText: 'Enter airplane type',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _passengersController,
              decoration: InputDecoration(
                labelText: 'Enter number of passengers',
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _speedController,
              decoration: InputDecoration(
                labelText: 'Enter maximum speed',
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _rangeController,
              decoration: InputDecoration(
                labelText: 'Enter range',
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          if (_selectedAirplane == null) ...[
            ElevatedButton(
              onPressed: () {
                final type = _typeController.text;
                final passengers = int.tryParse(_passengersController.text);
                final speed = int.tryParse(_speedController.text);
                final range = int.tryParse(_rangeController.text);

                if (type.isNotEmpty && passengers != null && speed != null && range != null) {
                  _addAirplane(type, passengers, speed, range);
                  _saveTextField(type);
                  _showSnackbar(buildContext, 'Airplane added!');
                  _clearForm();
                } else {
                  _showSnackbar(buildContext, 'Please fill all fields with valid values.');
                }
              },
              child: Text('Add Airplane'),
            ),
            ElevatedButton(
              onPressed: _copyPreviousData,
              child: Text('Copy Previous Data'),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () {
                final type = _typeController.text;
                final passengers = int.tryParse(_passengersController.text);
                final speed = int.tryParse(_speedController.text);
                final range = int.tryParse(_rangeController.text);

                if (type.isNotEmpty && passengers != null && speed != null && range != null) {
                  final airplane = Airplane(type, passengers, speed, range, id: _selectedAirplane!.id);
                  _updateAirplane(airplane);
                  _showSnackbar(buildContext, 'Airplane updated!');
                  _clearForm();
                } else {
                  _showSnackbar(buildContext, 'Please fill all fields with valid values.');
                }
              },
              child: Text('Update Airplane'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteAirplane(_selectedAirplane!);
                _showSnackbar(buildContext, 'Airplane deleted!');
                _clearForm();
              },
              child: Text('Delete Airplane'),
            ),
          ],
          Expanded(
            child: ListView.builder(
              itemCount: _airplanes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_airplanes[index].type),
                  subtitle: Text('Passengers: ${_airplanes[index].passengers}, Speed: ${_airplanes[index].speed} km/h, Range: ${_airplanes[index].range} km'),
                  onTap: () {
                    setState(() {
                      _selectedAirplane = _airplanes[index];
                      _typeController.text = _selectedAirplane!.type;
                      _passengersController.text = _selectedAirplane!.passengers.toString();
                      _speedController.text = _selectedAirplane!.speed.toString();
                      _rangeController.text = _selectedAirplane!.range.toString();
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
