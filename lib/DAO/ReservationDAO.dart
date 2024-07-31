import 'package:floor/floor.dart';
import '../modules/Reservation.dart';

@dao
abstract class ReservationDAO {
  @Query('SELECT * FROM Reservation')
  Future<List<Reservation>> getAllItems();

  @insert
  Future<void> insertItem(Reservation reservation);

  @delete
  Future<void> deleteItem(Reservation reservation);
}
