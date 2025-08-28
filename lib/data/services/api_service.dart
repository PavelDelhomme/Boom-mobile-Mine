
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({required this.baseUrl, http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> getAllStations() async {
    final response = await _client.get(Uri.parse('$baseUrl/stations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load stations');
    }
  }

  Future<Map<String, dynamic>> getStationById(String id) async {
    final response = await _client.get(Uri.parse('$baseUrl/stations/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load station');
    }
  }

  Future<void> saveStation(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/stations/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update station');
    }
  }

  Future<void> deleteStation(String id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/stations/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete station');
    }
  }

  Future<void> updateStation(String id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/stations/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update station');
    }
  }
}