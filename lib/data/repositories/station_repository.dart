import 'package:boom_mobile/domain/entities/station.dart';

abstract class StationRepository {
  Future<List<Station>> getAllStations();
  Future<Station?> getStationById(String id);
  Future<void> saveStation(Station station);
  Future<void> deleteStation(String id);
}