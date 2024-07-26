import 'package:floor/floor.dart';
import '../modules/Customer.dart';

@dao
abstract class CustomerDAO {
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> getAllCustomers();

  @insert
  Future<void> insertCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);
}
