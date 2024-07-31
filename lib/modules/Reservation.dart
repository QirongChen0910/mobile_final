import 'package:floor/floor.dart';

/// Represents a reservation entity in the database.
///
/// This class is used to define a reservation with a unique ID, name, associated customer name,
/// flight name, and reservation date.
@entity
class Reservation {

  /// Creates an instance of `Reservation`.
  ///
  /// [reservationName] The name of the reservation.
  /// [customerName] The name of the customer associated with the reservation.
  /// [flightName] The name of the flight for the reservation.
  /// [Date] The date of the reservation.
  /// [reservationID] The unique identifier for the reservation. If not provided, it will be auto-generated.
  Reservation(
      this.reservationName,
      this.customerName,
      this.flightName,
      this.Date, {
        this.reservationID,
      });

  /// The unique identifier for the reservation.
  ///
  /// This field is auto-generated and used as the primary key in the database.
  @PrimaryKey(autoGenerate: true)
  final int? reservationID;

  /// The name of the reservation.
  final String reservationName;

  /// The name of the customer associated with the reservation.
  final String customerName;

  /// The name of the flight for the reservation.
  final String flightName;

  /// The date of the reservation.
  final String Date;
}
