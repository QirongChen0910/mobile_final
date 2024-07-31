import 'package:flutter/material.dart';
import 'package:mobile_final/DAO/CustomerDAO.dart';
import 'package:mobile_final/modules/Customer.dart';
import 'package:mobile_final/utilities/AppDatabase.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/// A page displaying a list of customers and providing functionality
/// to add new customers.
///
/// This page includes text fields for entering customer details and
/// a list view for displaying existing customers. It also handles
/// loading and storing previous data using encrypted shared preferences.
class CustomerListPage extends StatefulWidget {
  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late CustomerDAO _customerDAO;
  List<Customer> _customers = [];
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();

  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  /// Initializes the database and loads customer data.
  Future<void> _initDb() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    _customerDAO = database.customerDAO;
    _loadCustomers();
    _loadPreviousData();
  }

  /// Loads all customers from the database and updates the state.
  Future<void> _loadCustomers() async {
    final customers = await _customerDAO.getAllCustomers();
    setState(() {
      _customers = customers;
    });
  }

  /// Loads previously stored data from encrypted shared preferences
  /// and populates the text fields.
  Future<void> _loadPreviousData() async {
    final prefs = await _prefs.getInstance();
    _firstNameController.text = prefs.getString('previousCustomerFirstName') ?? '';
    _lastNameController.text = prefs.getString('previousCustomerLastName') ?? '';
    _addressController.text = prefs.getString('previousCustomerAddress') ?? '';
    _birthdayController.text = prefs.getString('previousCustomerBirthday') ?? '';
  }

  /// Adds a new customer to the database.
  ///
  /// This method checks if all fields are filled, then inserts a new
  /// customer record into the database. After insertion, it clears
  /// the text fields and reloads the customer list.
  Future<void> _addCustomer() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final address = _addressController.text;
    final birthday = _birthdayController.text;

    if (firstName.isEmpty || lastName.isEmpty || address.isEmpty || birthday.isEmpty) {
      _showAlertDialog('Error', 'All fields must be filled.');
      return;
    }

    final customer = Customer(firstName, lastName, address, birthday);
    await _customerDAO.insertCustomer(customer);

    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _birthdayController.clear();
    _loadCustomers();
  }

  /// Displays an alert dialog with the specified [title] and [message].
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer List'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showAlertDialog('Instructions', 'This is the customer list page. You can add, view, update, and delete customers.');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: _birthdayController,
                  decoration: InputDecoration(labelText: 'Birthday'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addCustomer,
                  child: Text('Add Customer'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                return ListTile(
                  title: Text('${customer.firstName} ${customer.lastName}'),
                  subtitle: Text(customer.address),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailsPage(
                          customer: customer,
                          customerDao: _customerDAO,
                          onUpdate: _loadCustomers,
                        ),
                      ),
                    );
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

/// A page displaying the details of the specific customer and providing
/// functionality to update or delete the customer.
///
/// This page includes text fields for editing customer details and
/// buttons for updating or deleting the customer record.
class CustomerDetailsPage extends StatelessWidget {
  final Customer customer;
  final CustomerDAO customerDao;
  final Function onUpdate;

  CustomerDetailsPage({
    required this.customer,
    required this.customerDao,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final firstNameController = TextEditingController(text: customer.firstName);
    final lastNameController = TextEditingController(text: customer.lastName);
    final addressController = TextEditingController(text: customer.address);
    final birthdayController = TextEditingController(text: customer.birthday);

    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: birthdayController,
              decoration: InputDecoration(labelText: 'Birthday'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final updatedCustomer = Customer(
                      firstNameController.text,
                      lastNameController.text,
                      addressController.text,
                      birthdayController.text,
                      customerID: customer.customerID, // Ensure to retain the original ID
                    );
                    await customerDao.updateCustomer(updatedCustomer);
                    onUpdate();
                    Navigator.of(context).pop();
                  },
                  child: Text('Update'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await customerDao.deleteCustomer(customer);
                    onUpdate();
                    Navigator.of(context).pop();
                  },
                  child: Text('Delete'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
