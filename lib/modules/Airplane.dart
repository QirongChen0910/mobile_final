import 'package:floor/floor.dart';

@entity
class Airplane {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String type;
  final int passengers;
  final int speed;
  final int range;

  Airplane(this.type, this.passengers, this.speed, this.range, {this.id});
}
