import 'package:boom_mobile/data/repositories/station_repository.dart';
import 'package:boom_mobile/data/services/api_service.dart';
import 'package:boom_mobile/domain/entities/station.dart';

class StationRepositoryImpl implements StationRepository {
  final ApiService _apiService;

  StationRepositoryImpl(this._apiService);

  @override
  Future<List<Station>> getAllStations() async {
    try {
      final data = await _apiService.getAllStations();
      return data.map((json) => Station.fromJson(json)).toList();
    } catch (e) {
      // Retourner une liste vide en cas d'erreur
      return [];
    }
  }

  @override
  Future<Station?> getStationById(String id) async {
    try {
      final data = await _apiService.getStationById(id);
      return Station.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveStation(Station station) async {
    // Implémentation
  }

  @override
  Future<void> deleteStation(String id) async {
    // Implémentation
  }
}