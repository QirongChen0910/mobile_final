import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import '../modules/Customer.dart';
import '../modules/Flight.dart';
import '../utilities/AppDatabase.dart';
import '../DAO/ReservationDAO.dart';
import '../modules/Reservation.dart';
import '../DAO/CustomerDAO.dart';
import '../DAO/FlightDAO.dart';
import '../utilities/AppLocalizations.dart';

class AddReservationPage extends StatefulWidget {
  @override
  _AddReservationPageState createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  // Controllers for text fields
  late TextEditingController _controllerReservation;
  late TextEditingController _controllerDate;

  // Lists to hold reservations, customers, and flights data
  List<Reservation> reservations = [];
  List<Customer> customers = [];
  List<Flight> flights = [];

  // DAOs for database operations
  late ReservationDAO reservationDAO;
  late CustomerDAO customerDAO;
  late FlightDAO flightDAO;

  // Variables for selected reservation, customer, and flight
  Reservation? selectedReservation;
  String? selectedCustomer;
  String? selectedFlight;

  // EncryptedSharedPreferences instance for secure data storage
  final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _controllerReservation = TextEditingController();
    _controllerDate = TextEditingController();
    _initDatabase();
    loadSavedData();
  }

  // Initialize database and fetch data
  Future<void> _initDatabase() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    reservationDAO = database.reservationDao;
    customerDAO = database.customerDao;
    flightDAO = database.flightDao;

    final listOfReservations = await reservationDAO.getAllItems();
    final listOfCustomers = await customerDAO.getAllCustomers();
    final listOfFlights = await flightDAO.getAllFlights();

    setState(() {
      reservations = listOfReservations;
      customers = listOfCustomers;
      flights = listOfFlights;
    });
  }

  @override
  void dispose() {
    _controllerReservation.dispose();
    _controllerDate.dispose();
    super.dispose();
  }

  // Add a new reservation to the database
  void addReservation() async {
    if (selectedCustomer == null || selectedCustomer!.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error',
          'You must choose a customer.');
      return;
    }

    if (selectedFlight == null || selectedFlight!.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error',
          'You must choose a flight.');
      return;
    }

    if (_controllerDate.value.text.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error',
          'The date cannot be empty.');
      return;
    }

    if (_controllerReservation.value.text.isEmpty) {
      _showErrorDialog(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error',
          'Please enter a reservation name.');
      return;
    }

    final newItem = Reservation(
      _controllerReservation.value.text,
      selectedCustomer!,
      selectedFlight!,
      _controllerDate.value.text,
    );

    await reservationDAO.insertItem(newItem);

    final listOfReservations = await reservationDAO.getAllItems();

    setState(() {
      reservations = listOfReservations;
    });
  }

  // Save the current data to encrypted shared preferences
  void saveData() {
    _encryptedPrefs.setString("customerName", selectedCustomer!);
    _encryptedPrefs.setString("flightName", selectedFlight!);
    _encryptedPrefs.setString("flightDate", _controllerDate.value.text);
    _encryptedPrefs.setString("reservationName", _controllerReservation.value.text);
  }

  // Load saved data from encrypted shared preferences
  void loadSavedData() {
    _encryptedPrefs.getString("customerName").then((customerName) {
      if (customerName != null) {
        setState(() {
          selectedCustomer = customerName;
        });
      }
    });
    _encryptedPrefs.getString("flightName").then((flightName) {
      if (flightName != null) {
        setState(() {
          selectedFlight = flightName;
        });
      }
    });
    _encryptedPrefs.getString("flightDate").then((flightDate) {
      if (flightDate != null) {
        setState(() {
          _controllerDate.text = flightDate;
        });
      }
    });

    _encryptedPrefs.getString("reservationName").then((reservationName) {
      if (reservationName != null) {
        setState(() {
          _controllerReservation.text = reservationName;
        });
      }
    });
  }

  // Remove saved data from encrypted shared preferences
  void removeData(){
    setState(() {
      _encryptedPrefs.remove("customerName");
      _encryptedPrefs.remove("flightName");
      _encryptedPrefs.remove("flightDate");
      _encryptedPrefs.remove("reservationName");
      _controllerReservation.clear();
      _controllerDate.clear();
      selectedCustomer = null;
      selectedFlight = null;
    });
  }

  // Show an error dialog with a title and message
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.translate('errorTitle') ?? 'OK'),
            ),
          ],
        );
      },
    );
  }

  // Show a confirmation Snackbar before deleting a reservation
  void showConfirmDeleteSnackBar(Reservation reservation) {
    final snackBar = SnackBar(
      content: Text(AppLocalizations.of(context)?.translate('confirmDeleteMessage') ?? 'Do you want to delete this reservation?'),
      action: SnackBarAction(
        label: AppLocalizations.of(context)?.translate('delete') ?? 'Clear saved data',
        onPressed: () {
          removeReservation(reservation);
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Show a dialog asking whether to save data
  void showSaveDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('saveDataDialogTitle') ?? 'Save Data Dialog'),
          content: Text(AppLocalizations.of(context)?.translate('saveDataDialogMessage') ?? 'Do you want to save data on this page?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                saveData();
              },
              child: Text(AppLocalizations.of(context)?.translate('yes') ?? 'Yes'),
            ),
            TextButton(
              onPressed: () {
                removeData();
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)?.translate('no') ?? 'No'),
            ),
          ],
        );
      },
    );
  }

  // Remove a reservation from the database
  Future<void> removeReservation(Reservation reservation) async {
    await reservationDAO.deleteItem(reservation);
    setState(() {
      reservations.remove(reservation);
      selectedReservation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    // Responsive layout based on screen width
    if (width > height && width > 720) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)?.translate('addReservation') ?? 'Add Reservations Page'),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 1,
              child: ToDoList(),
            ),
            Expanded(
              flex: 1,
              child: DetailsPage(),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(AppLocalizations.of(context)?.translate('addReservation') ?? 'Add Reservations Page'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: ToDoList(),
            ),
          ],
        ),
      );
    }
  }

  // Widget for displaying the list of reservations and controls for adding new ones
  Widget ToDoList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: DropdownButton<String>(
            hint: Text(AppLocalizations.of(context)?.translate('selectCustomer') ?? 'Select Customer'),
            value: selectedCustomer,
            onChanged: (String? newValue) {
              setState(() {
                selectedCustomer = newValue;
              });
            },
            items: customers.map((Customer customer) {
              return DropdownMenuItem<String>(
                value: '${customer.firstName} ${customer.lastName}',
                child: Text('${customer.firstName} ${customer.lastName}'),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(AppLocalizations.of(context)?.translate('selectFlight') ?? 'Select Flight'),
            value: selectedFlight,
            onChanged: (String? newValue) {
              setState(() {
                selectedFlight = newValue;
              });
            },
            items: flights.map((Flight flight) {
              return DropdownMenuItem<String>(
                value: flight.flightName,
                child: Text(flight.flightName),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          child: TextField(
            controller: _controllerDate,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: AppLocalizations.of(context)?.translate('enterDate') ?? 'Enter the Date you want',
            ),
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextField(
                controller: _controllerReservation,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppLocalizations.of(context)?.translate('enterReservationName') ?? 'Enter the reservation name',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                addReservation();
                showSaveDataDialog();
              },
              child: Text(AppLocalizations.of(context)?.translate('addReservation') ?? 'Add a reservation'),
            ),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(
                onTap: () {
                  if (MediaQuery.of(context).size.width < 720) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReservationDetailsPage(reservation: reservations[rowNum], flightDAO: flightDAO,),
                      ),
                    );
                  } else {
                    setState(() {
                      selectedReservation = reservations[rowNum];
                    });
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('${AppLocalizations.of(context)?.translate('reservationName') ?? 'Reservation Name'} : ${reservations[rowNum].reservationName}'),
                    Text('${AppLocalizations.of(context)?.translate('customerName') ?? 'Customer Name'} : ${reservations[rowNum].customerName}'),
                    Text('${AppLocalizations.of(context)?.translate('flightName') ?? 'Flight Name'} : ${reservations[rowNum].flightName}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget for displaying details of the selected reservation
  Widget DetailsPage() {
    // Find the selected flight from the list of flights
    Flight? selectedFlightDetails;
    for (var flight in flights) {
      if (flight.flightName == selectedReservation?.flightName) {
        selectedFlightDetails = flight;
        break;
      }
    }
    if (selectedReservation == null) {
      return Center(child: Text(AppLocalizations.of(context)?.translate('noReservation') ?? 'No Reservation'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reservation ID: ${selectedReservation?.reservationID}'),
          Text('${AppLocalizations.of(context)?.translate('reservationName') ?? 'Reservation Name'} : ${selectedReservation?.reservationName}'),
          Text('${AppLocalizations.of(context)?.translate('customerName') ?? 'Customer Name'} : ${selectedReservation?.customerName}'),
          Text('${AppLocalizations.of(context)?.translate('flightName') ?? 'Flight Name'} : ${selectedReservation?.flightName}'),
          Text('${AppLocalizations.of(context)?.translate('departureCity') ?? 'Departure City'} : ${selectedFlightDetails?.departureCity}'),
          Text('${AppLocalizations.of(context)?.translate('destination') ?? 'Destination'} : ${selectedFlightDetails?.destination}'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (selectedReservation != null) {
                showConfirmDeleteSnackBar(selectedReservation!);
              }
            },
            child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete'),
          ),
        ],
      ),
    );
  }
}

class ReservationDetailsPage extends StatefulWidget {
  final Reservation reservation;
  final FlightDAO flightDAO;

  // Constructor to receive Reservation and FlightDAO instances
  ReservationDetailsPage({required this.reservation, required this.flightDAO});

  @override
  _ReservationDetailsPageState createState() => _ReservationDetailsPageState();
}

class _ReservationDetailsPageState extends State<ReservationDetailsPage> {
  // Variable to store the details of the selected flight
  Flight? selectedFlightDetails;

  @override
  void initState() {
    super.initState();
    // Load flight details when the widget is initialized
    _loadFlightDetails();
  }

  // Method to fetch flight details from the database
  Future<void> _loadFlightDetails() async {
    // Retrieve all flights from the database
    final flights = await widget.flightDAO.getAllFlights();

    // Find the flight that matches the reservation's flightName
    for (var flight in flights) {
      if (flight.flightName == widget.reservation.flightName) {
        setState(() {
          // Update the state with the found flight details
          selectedFlightDetails = flight;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title of the app bar
        title: Text(AppLocalizations.of(context)?.translate('reservationDetails') ?? 'Reservation Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display reservation details
            Text('Reservation ID: ${widget.reservation.reservationID}'),
            Text('${AppLocalizations.of(context)?.translate('reservationName') ?? 'Reservation Name'} : ${widget.reservation.reservationName}'),
            Text('${AppLocalizations.of(context)?.translate('customerName') ?? 'Customer Name'} : ${widget.reservation.customerName}'),
            Text('${AppLocalizations.of(context)?.translate('flightName') ?? 'Flight Name'} : ${widget.reservation.flightName}'),

            // Display flight details if available
            if (selectedFlightDetails != null) ...[
              Text('${AppLocalizations.of(context)?.translate('departureCity') ?? 'Departure City'} : ${selectedFlightDetails!.departureCity}'),
              Text('${AppLocalizations.of(context)?.translate('destination') ?? 'Destination'} : ${selectedFlightDetails!.destination}'),
            ],

            SizedBox(height: 20),

            // Button to navigate back to the previous screen
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)?.translate('back') ?? 'Back'),
            ),
          ],
        ),
      ),
    );
  }
}


