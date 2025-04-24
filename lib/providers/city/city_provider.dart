import 'package:e_commerce/models/city/city_model.dart';
import 'package:e_commerce/repository/city/city_repository.dart';
import 'package:flutter/material.dart';

class CityProvider with ChangeNotifier {
  final CityRepository _repository = CityRepository();

  List<CityModel> _cities = [];
  String? _errorMessage;
  bool _isLoading = false;

  List<CityModel> get cities => _cities;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  List<String> _cityNames = []; // Store city names
  List<String> get cityNames => _cityNames; // Getter for cityNames

  Future<void> fetchCities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _repository.getCities();

    if (response['success']) {
      _cities = response['data'] as List<CityModel>;
      // Extract city names and store in cityNames
      _cityNames = _cities.map((city) => city.name).toList();
    } else {
      _errorMessage = response['message'];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Method to get city by name
  String? getCityIdByName(String cityName) {
    final city = _cities.firstWhere(
      (city) => city.name == cityName,
      orElse: () => CityModel(id: '', name: ''),
    );
    return city.id;
  }
}
