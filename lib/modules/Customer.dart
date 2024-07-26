import 'package:floor/floor.dart';

@entity
class Customer {

  @PrimaryKey(autoGenerate:true)
  final int? customerID;
  final String firstName ;
  final String lastName;


  Customer( this.firstName,this.lastName,{this.customerID});

}
