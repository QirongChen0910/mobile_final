import 'package:flutter/material.dart';
import '../utilities/AppDatabase.dart'; // 替换为你的实际路径
import '../modules/Customer.dart';
import '../DAO/CustomerDAO.dart';

class CustomerListPage extends StatefulWidget {
  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late AppDatabase database;
  late CustomerDAO customerDAO;
  final TextEditingController _customerIDController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    try {
      database = await $FloorAppDatabase.databaseBuilder('app_database1.db').build();
      customerDAO = database.customerDAO;
      print('Database initialized');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  void _insertCustomer() async {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      try {
        final customer = Customer(firstName, lastName);
        await customerDAO.insertCustomer(customer);

        // 清除文本框
        _firstNameController.clear();
        _lastNameController.clear();

        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer added successfully!')),
        );
      } catch (e) {
        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding customer: $e')),
        );
      }
    } else {
      // 显示错误消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer List Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 8),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'First Name',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Last Name',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _insertCustomer,
              child: const Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}
