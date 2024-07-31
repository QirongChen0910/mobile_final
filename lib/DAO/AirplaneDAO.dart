import 'package:floor/floor.dart';
import '../modules/Airplane.dart';

@dao
abstract class AirplaneDAO {
  @Query('SELECT * FROM Airplane')
  Future<List<Airplane>> getAllAirplanes();

  @insert
  Future<void> insertAirplane(Airplane airplane);

  @update
  Future<void> updateAirplane(Airplane airplane);

  @delete
  Future<void> deleteAirplane(Airplane airplane);
}
