import 'package:flutter/material.dart';
import '../modules/Customer.dart';
import '../utilities/AppDatabase.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:mobile_final/utilities/AppLocalizations.dart';
import 'package:flutter/services.dart';  // Import this package for TextInputFormatter

class CustomerListPage extends StatefulWidget {
  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  late AppDatabase _db;
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
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
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final data = await _db.customerDAO.getAllCustomers();
    setState(() {
      _customers = data;
      // Display the last record's information if available
      if (_customers.isNotEmpty) {
        final lastCustomer = _customers.last;
        _firstNameController.text = lastCustomer.firstName;
        _lastNameController.text = lastCustomer.lastName;
        _addressController.text = lastCustomer.address;
        _birthdayController.text = lastCustomer.birthday;
      }
    });
  }

  Future<void> _addCustomer() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final address = _addressController.text;
    final birthday = _birthdayController.text;

    if (firstName.isNotEmpty && lastName.isNotEmpty && address.isNotEmpty && birthday.isNotEmpty) {
      final customer = Customer(firstName, lastName, address, birthday);
      await _db.customerDAO.insertCustomer(customer);
      _loadCustomers();

      _saveData();

      _firstNameController.clear();
      _lastNameController.clear();
      _addressController.clear();
      _birthdayController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.translate('customerAdded') ?? 'Customer added')),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error'),
          content: Text(AppLocalizations.of(context)?.translate('allFieldsRequired') ?? 'All fields are required.'),
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

  Future<void> _updateCustomer(int id) async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final address = _addressController.text;
    final birthday = _birthdayController.text;

    if (firstName.isNotEmpty && lastName.isNotEmpty && address.isNotEmpty && birthday.isNotEmpty) {
      final customer = Customer(firstName, lastName, address, birthday, customerID: id);
      await _db.customerDAO.updateCustomer(customer);
      _loadCustomers();

      _saveData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.translate('customerUpdated') ?? 'Customer updated')),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error'),
          content: Text(AppLocalizations.of(context)?.translate('allFieldsRequired') ?? 'All fields are required.'),
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

  Future<void> _deleteCustomer(Customer customer) async {
    await _db.customerDAO.deleteCustomer(customer);
    _loadCustomers();
    if (_selectedCustomer == customer) {
      setState(() {
        _selectedCustomer = null;
      });
    }
  }

  void _onItemTap(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _firstNameController.text = customer.firstName;
      _lastNameController.text = customer.lastName;
      _addressController.text = customer.address;
      _birthdayController.text = customer.birthday;
    });
  }

  void _saveData() {
    _encryptedPrefs.setString('firstName', _firstNameController.text);
    _encryptedPrefs.setString('lastName', _lastNameController.text);
    _encryptedPrefs.setString('address', _addressController.text);
    _encryptedPrefs.setString('birthday', _birthdayController.text);
  }

  void _loadSavedData() async {
    _firstNameController.text = await _encryptedPrefs.getString('firstName') ?? '';
    _lastNameController.text = await _encryptedPrefs.getString('lastName') ?? '';
    _addressController.text = await _encryptedPrefs.getString('address') ?? '';
    _birthdayController.text = await _encryptedPrefs.getString('birthday') ?? '';
  }

  void _clearInputFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _addressController.clear();
    _birthdayController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)?.translate('fieldsCleared') ?? 'Input fields cleared')),
    );
  }

  void _validateBirthdayInput(String value) {
    // Check if the input contains any non-numeric characters
    final regex = RegExp(r'^[0-9]*$');
    if (!regex.hasMatch(value)) {
      // Show alert if invalid input
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error'),
          content: Text(AppLocalizations.of(context)?.translate('invalidBirthday') ?? 'Invalid birthday format. Please enter numbers only.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)?.translate('ok') ?? 'OK'),
            ),
          ],
        ),
      );
      // Clear the invalid input
      _birthdayController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)?.translate('customerListPage') ?? 'Customers List'),
        actions: [
          OutlinedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(AppLocalizations.of(context)?.translate('instructions') ?? 'Instructions'),
                  content: Text(
                      AppLocalizations.of(context)?.translate('instructionsMessage') ??
                          ''
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
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.translate('firstName') ?? 'Enter first name',
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
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.translate('lastName') ?? 'Enter last name',
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
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.translate('address') ?? 'Enter address',
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
                    controller: _birthdayController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)?.translate('birthday') ?? 'Enter birthday',
                    ),
                    keyboardType: TextInputType.number, // Ensure only numeric keyboard is shown
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // Allow only digits
                      LengthLimitingTextInputFormatter(10), // Optional: Limit length to 10
                    ],
                    onChanged: _validateBirthdayInput, // Validate on input change
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addCustomer,
                    child: Text(AppLocalizations.of(context)?.translate('addCustomer') ?? 'Add Customer'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedCustomer != null) {
                        _updateCustomer(_selectedCustomer!.customerID!);
                      }
                    },
                    child: Text(AppLocalizations.of(context)?.translate('update') ?? 'Update Customer'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedCustomer != null) {
                        _deleteCustomer(_selectedCustomer!);
                      }
                    },
                    child: Text(AppLocalizations.of(context)?.translate('deleteCustomer') ?? 'Delete Customer'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return ListTile(
                    title: Text('${customer.firstName} ${customer.lastName}'),
                    onTap: () => _onItemTap(customer),
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
