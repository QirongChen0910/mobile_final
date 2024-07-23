class Customer {
  int? id;
  String firstName;
  String lastName;
  String address;
  DateTime birthday;

  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.birthday,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'birthday': birthday.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      address: map['address'],
      birthday: DateTime.parse(map['birthday']),
    );
  }
}
