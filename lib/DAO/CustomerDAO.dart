import 'package:floor/floor.dart';
import '../modules/Customer.dart';

/// The Data Access Object (DAO) for the `Customer` entity.
///
/// Provides methods for querying, inserting, updating, and deleting
/// customer records in the database.
@dao
abstract class CustomerDAO {

  /// Retrieves all customers from database.
  ///
  /// Returns a [Future] that completes with a [List] of [Customer] objects.
  @Query('SELECT * FROM Customer')
  Future<List<Customer>> getAllCustomers();

  /// Inserts a new customer into the database.
  ///
  /// The [customer] parameter must be a [Customer] object to be inserted.
  @insert
  Future<void> insertCustomer(Customer customer);

  /// Updates an existing customer in the database.
  ///
  /// The [customer] parameter must be a [Customer] object with updated values.
  @update
  Future<void> updateCustomer(Customer customer);

  /// Deletes a customer from the database.
  ///
  /// The [customer] parameter must be a [Customer] object to be deleted.
  @delete
  Future<void> deleteCustomer(Customer customer);
}
