import 'package:floor/floor.dart';

@entity
class Reservation {

  @PrimaryKey(autoGenerate:true)
  final int? reservationID;
  final String reservationName;
  final String customerName;
  final String flightName;
  final String Date;



  Reservation(this.reservationName,this.customerName,this.flightName,this.Date,{this.reservationID});


}
