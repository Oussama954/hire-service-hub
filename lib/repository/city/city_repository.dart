import 'dart:convert';
import 'package:e_commerce/models/city/city_model.dart';
import 'package:e_commerce/services/city/city_service.dart';

class CityRepository {
  final CityService _service = CityService();

  Future<Map<String, dynamic>> getCities() async {
    try {
      final response = await _service.fetchCities();
      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Parse JSON into List<CityModel>
        List<CityModel> cities = (data['data'] as List)
            .map((cityJson) => CityModel.fromJson(cityJson))
            .toList();

        return {
          "success": true,
          "data": cities,
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "An unknown error occurred.",
        };
      }
    } catch (error) {
      return {
        "success": false,
        "message": error.toString(),
      };
    }
  }
}
