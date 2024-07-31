import 'dart:async';
import 'package:floor/floor.dart';
import 'package:mobile_final/DAO/FlightDAO.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../modules/Customer.dart';
import '../DAO/CustomerDAO.dart';
import '../modules/Reservation.dart';
import '../DAO/ReservationDAO.dart';
import '../modules/Flight.dart';
import '../DAO/FlightDAO.dart';

part 'AppDatabase.g.dart';

/// Represents the main database class for the application.
///
/// This class uses the Floor library to manage the SQLite database and provides
/// access to the Data Access Objects (DAOs) for `Reservation`, `Customer`, and `Flight` entities.
@Database(version: 1, entities: [Reservation, Customer, Flight])
abstract class AppDatabase extends FloorDatabase {
  /// Provides access to the `ReservationDAO` for performing operations
  /// on `Reservation` entities.
  ReservationDAO get reservationDao;

  /// Provides access to the `CustomerDAO` for performing operations
  /// on `Customer` entities.
  CustomerDAO get customerDao;

  /// Provides access to the `FlightDAO` for performing operations
  /// on `Flight` entities.
  FlightDAO get flightDao;
}
