import 'dart:convert';
import 'package:e_commerce/services/authentication/auth_servcies.dart';
import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:http/http.dart' as http;

class CityService {
  Future<http.Response> fetchCities() async {
    String? accessToken = await AuthService.getAccessToken();
    if (accessToken == null) throw Exception("Access token is missing.");

    try {
      final response = await http.get(
        Uri.parse("${Constants.baseUrl}/api/city"),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      
      return response;
    } catch (e) {
      throw Exception('Failed to load cities: $e');
    }
  }
}
