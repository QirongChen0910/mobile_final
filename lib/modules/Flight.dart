import 'package:floor/floor.dart';

@entity
class Flight {

  @PrimaryKey(autoGenerate:true)
  final int?  flightID;
  final String flightName;
  final String departureCity ;
  final String destination;
  final String departureTime;
  final String arrivalTime;


  Flight(this.flightName, this.departureCity,this.destination,this.departureTime,this.arrivalTime,{this.flightID});


}

