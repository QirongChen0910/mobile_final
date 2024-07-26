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

@Database(version: 1, entities: [Reservation,Customer,Flight])
abstract class AppDatabase extends FloorDatabase {
  ReservationDAO get reservationDao;
  CustomerDAO get customerDao;
  FlightDAO get flightDao;
}
