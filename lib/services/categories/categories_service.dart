import 'package:e_commerce/services/authentication/auth_servcies.dart';
import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  Future<http.Response> fetchCategories() async {
    String? accessToken = await AuthService.getAccessToken();
    if (accessToken == null) throw Exception("Access token is missing.");

    final url = Uri.parse("${Constants.baseUrl}${Constants.userCategory}");
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      return response;
    } catch (error) {
      throw Exception("Failed to fetch categories: $error");
    }
  }
}
