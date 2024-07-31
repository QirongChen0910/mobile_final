import 'package:floor/floor.dart';

/// Entity class representing a flight.
///
/// This class is annotated with `@entity` to indicate that it represents a table
/// in the database. Each instance of this class corresponds to a row in the table.
@entity
class Flight {

  /// The primary key for the flight table. It is auto-generated.
  @PrimaryKey(autoGenerate:true)
  final int? flightID;

  /// The name of the flight.
  final String flightName;

  /// The city from which the flight departs.
  final String departureCity;

  /// The destination city of the flight.
  final String destination;

  /// The departure time of the flight.
  final String departureTime;

  /// The arrival time of the flight.
  final String arrivalTime;

  /// Creates a [Flight] instance.
  ///
  /// [flightName] is the name of the flight.
  /// [departureCity] is the city from which the flight departs.
  /// [destination] is the destination city of the flight.
  /// [departureTime] is the departure time of the flight.
  /// [arrivalTime] is the arrival time of the flight.
  /// [flightID] is the primary key of the flight table, which is optional and auto-generated.
  Flight(this.flightName, this.departureCity, this.destination, this.departureTime, this.arrivalTime, {this.flightID});
}
