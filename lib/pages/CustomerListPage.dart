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
      _clearInputFields();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.translate('customerAdded') ?? 'Customer added')),
      );
    } else {
      _showErrorDialog();
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
      _showErrorDialog();
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
    final regex = RegExp(r'^[0-9]*$');
    if (!regex.hasMatch(value)) {
      _showErrorDialog(errorMessage: AppLocalizations.of(context)?.translate('invalidBirthday') ?? 'Invalid birthday format. Please enter numbers only.');
      _birthdayController.clear();
    }
  }

  void _showErrorDialog({String errorMessage = 'All fields are required.'}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.translate('errorTitle') ?? 'Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.translate('ok') ?? 'OK'),
          ),
        ],
      ),
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
            title: Text(AppLocalizations.of(context)?.translate('customerListPage') ?? 'Customers List'),
            actions: [
              OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)?.translate('instructions') ?? 'Instructions'),
                      content: Text(
                          AppLocalizations.of(context)?.translate('instructionsMessage') ?? ''
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
                Expanded(child: _buildCustomerList()),
                VerticalDivider(),
                if (_selectedCustomer != null)
                  Expanded(child: _buildDetailsPage(_selectedCustomer!)),
              ],
            )
                : _selectedCustomer == null
                ? _buildCustomerList()
                : _buildDetailsPage(_selectedCustomer!),
          ),
        );
      },
    );
  }

  Widget _buildCustomerList() {
    return Column(
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
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: _validateBirthdayInput,
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
                child: Text(AppLocalizations.of(context)?.translate('delete') ?? 'Delete Customer'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _clearInputFields,
                child: Text(AppLocalizations.of(context)?.translate('clear') ?? 'Clear'),
              ),
            ),
          ],
        ),
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
    );
  }

  Widget _buildDetailsPage(Customer customer) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(AppLocalizations.of(context)?.translate('details') ?? 'Customer Details', style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 16),
          Text('${AppLocalizations.of(context)?.translate('firstName') ?? 'First Name'}: ${customer.firstName}'),
          SizedBox(height: 8),
          Text('${AppLocalizations.of(context)?.translate('lastName') ?? 'Last Name'}: ${customer.lastName}'),
          SizedBox(height: 8),
          Text('${AppLocalizations.of(context)?.translate('address') ?? 'Address'}: ${customer.address}'),
          SizedBox(height: 8),
          Text('${AppLocalizations.of(context)?.translate('birthday') ?? 'Birthday'}: ${customer.birthday}'),
        ],
      ),
    );
  }
}
