import 'package:e_commerce/models/service/create_service_model.dart';
import 'package:e_commerce/models/service/fetch_signle_service_model.dart';
import 'package:e_commerce/models/service/service_model.dart';
import 'package:e_commerce/providers/service/service_filter_provider.dart';
import 'package:e_commerce/repository/service/service_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceRepository serviceRepository = ServiceRepository();

  List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;
  bool _isLoading = false;
  String? _errorMessage = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String? _errorMessageForServiceDetails = '';
  String? get errorMessageForServiceDetails => _errorMessageForServiceDetails;

  List<String> _cityNames = [];
  List<String> get cityNames => _cityNames;

  bool _isFilterApplied = false;
  List<ServiceModel> get filteredServices =>
      _isFilterApplied ? _filterServices : _services;

  bool get isFilterApplied => _isFilterApplied;

  List<ServiceModel> _myServices = [];
  List<ServiceModel> get myServices => _myServices;

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();
    try {
      _services = await serviceRepository.getServices();
      _isFilterApplied = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyServices() async {
    _isLoading = true;
    notifyListeners();
    try {
      _myServices = await serviceRepository.getMyServices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  FetchSingleService? _service;
  FetchSingleService? get service => _service;

  Future<void> fetchSingleServiceDetail(String serviceId) async {
    _isLoading = true;
    _errorMessageForServiceDetails = null;
    notifyListeners();

    final result = await serviceRepository.getService(serviceId);

    if (result != null) {
      _service = result;
    } else {
      _errorMessageForServiceDetails = "Failed to fetch the service.";
    }

    _isLoading = false;
    notifyListeners();
  }

  List<ServiceModel> _filterServices = [];

  List<ServiceModel> get filterServices => _filterServices;

// Fetch services based on filters
  Future<void> fetchFilterServices({
    String? categoryId,
    String? cityId,
    String? priceRangetype,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // Check if any filters are applied
      bool hasFilters = (categoryId != null && categoryId.isNotEmpty) || 
                        (cityId != null && cityId.isNotEmpty) || 
                        (priceRangetype != null && priceRangetype.isNotEmpty);
      
      // Set filter flag based on whether filters were applied, not results
      _isFilterApplied = hasFilters;
      
      if (hasFilters) {
        // Only call filter API if filters are applied
        _filterServices = await serviceRepository.getFilterServices(
          categoryId: categoryId,
          cityId: cityId,
          priceRangeType: priceRangetype,
        );
        print('Filter applied with results: ${_filterServices.length}');
      } else {
        // If no filters, use all services
        _filterServices = _services;
        _isFilterApplied = false;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFilters() {
    _isFilterApplied = false;
    _filterServices = [];
    notifyListeners();
  }

  void clearServicesList() {
    _services = [];
    notifyListeners();
  }
  
  // Search functionality
  String _searchQuery = "";
  List<ServiceModel> _searchResults = [];
  bool _isSearching = false;
  
  List<ServiceModel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  
  void searchServices(String query) {
    _searchQuery = query.toLowerCase().trim();
    _isSearching = _searchQuery.isNotEmpty;
    
    if (_isSearching) {
      // If filters are applied, search within filtered services, otherwise search all services
      final sourceList = _isFilterApplied ? _filterServices : _services;
      
      _searchResults = sourceList.where((service) {
        final nameMatch = service.serviceName?.toLowerCase().contains(_searchQuery) ?? false;
        final descMatch = service.description?.toLowerCase().contains(_searchQuery) ?? false;
        // CategoryId is available but we don't have direct access to category title
        // So we'll just search on name and description
        
        return nameMatch || descMatch;
      }).toList();
    } else {
      _searchResults = [];
    }
    
    notifyListeners();
  }
  
  void clearSearch() {
    _searchQuery = "";
    _isSearching = false;
    _searchResults = [];
    notifyListeners();
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  XFile? _coverPhoto;
  String _selectedCategory = '';
  String _selectedCity = '';
  bool _isAvailable = false;

  XFile? get coverPhoto => _coverPhoto;
  String get selectedCategory => _selectedCategory;
  String get selectedCity => _selectedCity;
  bool get isAvailable => _isAvailable;

  void setCoverPhoto(XFile photo) {
    _coverPhoto = photo;
    notifyListeners();
  }
  
  void clearCoverPhoto() {
    _coverPhoto = null;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  void toggleAvailability(bool value) {
    _isAvailable = value;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  CreateService? _createService;
  CreateService get createService => _createService!;
// Service management
  Future<bool> createServiceWithCoverPhoto(
      CreateService serviceData, String imagePath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      CreateService? result = await serviceRepository
          .createServiceWithCoverPhoto(serviceData, imagePath);

      if (result != null) {
        return true;
      } else {
        _errorMessage = "Failed to create service.";
        return false;
      }
    } catch (e) {
      print(e);

      // Extract the actual error message from the nested exception
      try {
        final message = e.toString();
        // Extract the last part of the message after the last "Exception:"
        final extractedMessage = message
            .split('Exception:')
            .last
            .trim(); // Trim to remove extra spaces
        _errorMessage = extractedMessage;
      } catch (parseError) {
        // Fallback in case parsing fails
        _errorMessage = "An error occurred: ${e.toString()}";
      }

      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadServiceCoverPhoto(
      String imagePath, String serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      CreateService? result =
          await serviceRepository.uploadServiceCoverPhoto(imagePath, serviceId);
      if (result != null) {
        _createService = result;
      } else {
        _errorMessage = "Failed to upload cover photo.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteService(String serviceId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool isDeleted = await serviceRepository.deleteService(serviceId);
      if (isDeleted) {
        _services.removeWhere((service) => service.id == serviceId);
        _filterServices.removeWhere((service) => service.id == serviceId);
        notifyListeners();
      } else {
        _errorMessage = "Failed to delete service.";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetCreateServiceValues() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    startTimeController.clear();
    endTimeController.clear();
    _coverPhoto = null;
    _selectedCategory = '';
    _selectedCity = '';
    _isAvailable = false;
    notifyListeners();
  }

  Future<bool> updateService(
      String serviceId, CreateService updatedService) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 SERVICE PROVIDER: updateService method called');
      print('🔹 Service ID: $serviceId');
      print('🔹 Service Name: ${updatedService.serviceName}');
      print('🔹 Category: ${updatedService.categoryId}');
      print('🔹 City: ${updatedService.cityId}');
      
      // Convert the ServiceModel to a Map - FIXED: complete map with all fields
      final serviceData = {
        "title": updatedService.serviceName, // Backend expects 'title' instead of 'service_name'
        "description": updatedService.description,
        "category_id": updatedService.categoryId,
        "price": updatedService.price,
        "is_active": updatedService.isAvailable, // Backend expects 'is_active' instead of 'is_available'
        "start_time": updatedService.startTime,
        "end_time": updatedService.endTime,
        "city_id": updatedService.cityId,
      };
      
      print('🔹 Service Data being sent: $serviceData');
      
      // Call the repository to update the service
      final response = await serviceRepository.updateService(serviceId, serviceData);
      
      print('🔹 Service Update Response: $response');
      
      if (response['success'] == true) {
        print('✅ Service update successful');
        
        // Check if data exists and is in the expected format
        if (response['data'] != null) {
          print('🔹 Response data exists: ${response['data']}');
          
          if (response['data'] is List && response['data'].isNotEmpty) {
            print('✅ Response data is a non-empty list');
          } else {
            print('⚠️ Response data is not a list or is empty: ${response['data']}');
          }
        } else {
          print('⚠️ Response data is null');
        }
        
        // Refresh service details and services list to show updated data
        print('🔄 Refreshing service data...');
        await fetchSingleServiceDetail(serviceId);
        await fetchMyServices(); // Refresh provider's services
        
        // Check if we're viewing filtered services, and refresh those too
        if (_isFilterApplied) {
          await fetchFilterServices();
        } else {
          await fetchServices(); // Refresh all services if not filtered
        }
        
        notifyListeners();
        return true;
      } else {
        print('❌ Service update failed with error: ${response['message']}');
        _errorMessage = response['message'] ?? "Failed to update service.";
        return false;
      }
    } catch (e) {
      print('❌ Exception during service update: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
