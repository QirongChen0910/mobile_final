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
import '../DAO/AirplaneDAO.dart';
import '../modules/Airplane.dart';

part 'AppDatabase.g.dart';

@Database(version: 1, entities: [Customer, Flight, Reservation, Airplane])
abstract class AppDatabase extends FloorDatabase {
  CustomerDAO get customerDAO;
  FlightDAO get flightDAO;
  ReservationDAO get reservationDAO;
  AirplaneDAO get airplaneDAO;
}