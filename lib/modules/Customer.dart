import 'package:floor/floor.dart';

@Entity(tableName: 'Customer')
class Customer {
  @PrimaryKey(autoGenerate: true)
  final int? customerID;
  final String firstName;
  final String lastName;
  final String address;
  final String birthday;

  Customer(this.firstName,this.lastName,this.address, this.birthday,{this.customerID});
}
