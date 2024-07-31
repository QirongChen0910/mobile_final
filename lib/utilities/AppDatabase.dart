// lib/utilities/AppDatabase.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../DAO/AirplaneDAO.dart';
import '../modules/Airplane.dart';
import '../DAO/CustomerDAO.dart';
import '../modules/Customer.dart';
import '../DAO/FlightDAO.dart';
import '../modules/Flight.dart';
import '../DAO/ReservationDAO.dart';
import '../modules/Reservation.dart';

part 'AppDatabase.g.dart';

@Database(version: 1, entities: [Customer, Flight, Reservation, Airplane])
abstract class AppDatabase extends FloorDatabase {
  CustomerDAO get customerDAO;
  FlightDAO get flightDAO;
  ReservationDAO get reservationDAO;
  AirplaneDAO get airplaneDAO;
}
