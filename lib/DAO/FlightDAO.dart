import 'package:floor/floor.dart';
import '../modules/Flight.dart';

@dao
abstract class FlightDAO {
  @Query('SELECT * FROM Flight')
  Future<List<Flight>> getAllFlights();

  @insert
  Future<void> insertFlight(Flight flight);

  @delete
  Future<void> deleteFlight(Flight flight);
}
