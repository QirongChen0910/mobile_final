import 'package:flutter/material.dart';
import '../modules/Customer.dart';
import '../modules/Flight.dart';
import '../utilities/AppDatabase.dart';
import '../DAO/ReservationDAO.dart';
import '../modules/Reservation.dart';
import '../DAO/CustomerDAO.dart';
import '../DAO/FlightDAO.dart';

class AddReservationPage extends StatefulWidget {
  @override
  _AddReservationPageState createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  late TextEditingController _controller;
  late TextEditingController _controllerDate;
  List<Reservation> reservations = [];
  List<Customer> customers = [];
  List<Flight> flights = [];
  late ReservationDAO reservationDAO;
  late CustomerDAO customerDAO;
  late FlightDAO flightDAO;
  Reservation? selectedReservation;
  String? selectedCustomer;
  String? selectedFlight;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controllerDate = TextEditingController();
    _initDatabase();
  }

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
    _controller.dispose();
    _controllerDate.dispose();
    super.dispose();
  }

  void addReservation() async {
    if (_controller.value.text.isNotEmpty) {
      // 创建一个新的 Reservation 对象，但不设置 reservationID，因为它是自动生成的
      final newItem = Reservation(_controller.value.text, selectedCustomer!, selectedFlight!, _controllerDate.value.text);

      // 插入新的 Reservation 对象
      await reservationDAO.insertItem(newItem);

      // 获取所有 Reservation 对象，包括新插入的那个
      final listOfReservations = await reservationDAO.getAllItems();

      // 更新状态以刷新 UI
      setState(() {
        reservations = listOfReservations;
        _controller.clear();
      });
    }
  }


  void removeReservation(Reservation reservation) async {
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
    if ((width > height) && (width > 720)) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Add Reservations Page'),
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
      // Phone version or tablet in portrait mode
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text('Add Reservations Page'),
        ),
        body: Column(
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
    }
  }

  Widget ToDoList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // DropdownButton for a customer.
        SizedBox(
          width: double.infinity,
          child: DropdownButton<String>(
            hint: Text('Select Customer'),
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

        // DropdownButton for a Flight.
        SizedBox(
          width: double.infinity,
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text('Select Flight'),
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

        // Text field for choosing a flight date.
        Expanded(
          child: TextField(
            controller: _controllerDate,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Enter the Date you want",
            ),
          ),
        ),
        SizedBox(height: 16),

        // TextField for reservation name.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Enter the reservation name",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: addReservation,
              child: Text("Add a reservation"),
            ),
          ],
        ),
        SizedBox(height: 16),

        // ListView for Reservation
        Expanded(
          child: ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, rowNum) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedReservation = reservations[rowNum];
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("ReservationName:" + reservations[rowNum].reservationName),
                    Text("CustomerName: " + reservations[rowNum].customerName),
                    Text("FlightName: " + reservations[rowNum].flightName),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget DetailsPage() {
    if (selectedReservation == null) {
      return Center(child: Text('No Reservation'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reservation ID: ${selectedReservation?.reservationID}'),
          Text('Reservation Name : ${selectedReservation?.reservationName}'),
          Text('Customer Name : ${selectedReservation?.customerName}'),
          Text('Flight Name : ${selectedReservation?.flightName}'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              removeReservation(selectedReservation!);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
