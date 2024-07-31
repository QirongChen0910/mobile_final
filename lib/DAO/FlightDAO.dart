import 'package:floor/floor.dart';
import '../modules/Flight.dart';

/// Data Access Object (DAO) for the [Flight] entity.
///
/// This class provides methods to interact with the `Flight` table in the database.
@dao
abstract class FlightDAO {

  /// Retrieves all flights from the `Flight` table.
  ///
  /// Returns a [Future] containing a list of all [Flight] objects.
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> getAllFlights();

  /// Inserts a new flight into the `Flight` table.
  ///
  /// [flight] is the [Flight] object to be inserted.
  /// Returns a [Future] that completes when the operation is done.
  @insert
  Future<void> insertFlight(Flight flight);

  /// Deletes a flight from the `Flight` table.
  ///
  /// [flight] is the [Flight] object to be deleted.
  /// Returns a [Future] that completes when the operation is done.
  @delete
  Future<void> deleteFlight(Flight flight);

  /// Updates an existing flight in the `Flight` table.
  ///
  /// [flight] is the [Flight] object to be updated.
  /// Returns a [Future] that completes when the operation is done.
  @update
  Future<void> updateFlight(Flight flight);
}
