import 'package:floor/floor.dart';

@entity
class Flight {
  @primaryKey
  final String flightID;
  final String departureCity ;
  final String destination;
  final String departureTime;
  final String arrivalTime;


  Flight(this.flightID, this.departureCity,this.destination,this.departureTime,this.arrivalTime);


}
