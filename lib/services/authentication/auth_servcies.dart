import 'dart:convert';
import 'dart:io';
import 'package:e_commerce/utils/api_constnsts.dart';
import 'package:e_commerce/utils/device_info/get_device_info.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show utf8, base64Url;

class AuthService {
  // Keys for accessing tokens in SharedPreferences
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';

  // Store tokens in SharedPreferences
  static Future<void> storeTokens(
      String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(accessTokenKey, accessToken);
    await prefs.setString(refreshTokenKey, refreshToken);
  }

  // Get user data from JWT token
  static Future<Map<String, dynamic>?> getUserDataFromToken() async {
    try {
      final String? token = await getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }
      
      // JWT tokens are three parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      
      // Decode the payload (middle part)
      String normalizedPayload = parts[1];
      // Add padding if needed
      while (normalizedPayload.length % 4 != 0) {
        normalizedPayload += '=';
      }
      
      // Base64 decode
      final payloadBytes = base64Url.decode(normalizedPayload);
      final payloadString = utf8.decode(payloadBytes);
      
      // Parse JSON
      return json.decode(payloadString);
    } catch (e) {
      print('Error extracting user data from token: $e');
      return null;
    }
  }
  
  // Get user ID from token directly
  static Future<String?> getUserIdFromToken() async {
    final userData = await getUserDataFromToken();
    return userData?['userId'] as String?;
  }

  // Retrieve access token from SharedPreferences
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(accessTokenKey);
  }

  // Retrieve refresh token from SharedPreferences
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(refreshTokenKey);
  }

  // Optionally, you can create a method to clear tokens
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
  }

  Map<String, String> _generateHeaders({String? accessToken}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<http.Response> registerUser({
    required String email,
    required String phone,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final url =
        Uri.parse('${Constants.baseUrl}${Constants.userApiPath}/register');

    final body = json.encode({
      'email': email,
      'phone': phone,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
    });

    try {
      final response = await http
          .post(
            url,
            headers: _generateHeaders(),
            body: body,
          )
          .timeout(const Duration(seconds: 10));
      print(response.body);
      return response;
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to register user');
    }
  }

  Future<http.Response> verifyAccount({
    required String email,
    required String otp,
  }) async {
    final url =
        Uri.parse('${Constants.baseUrl}${Constants.userApiPath}/verify-user');

    final body = json.encode({
      'email': email,
      'otp': otp,
    });

    try {
      final response = await http.post(
        url,
        headers: _generateHeaders(),
        body: body,
      );
      print(response.statusCode);
      print(response.body);
      return response; // Returning the http.Response
    } catch (e) {
      print('Error during account verification: $e');
      throw Exception('Failed to verify account');
    }
  }

  // login method
  Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${Constants.baseUrl}${Constants.userApiPath}/login');

    final body = json.encode({
      'email': email,
      'password': password,
    });

    try {
      print('Making login request to: $url');
      print('Request body: $body');
      
      final response = await http.post(
        url,
        headers: _generateHeaders(),
        body: body,
      );
      
      print('Login response status code: ${response.statusCode}');
      print('Login response headers: ${response.headers}');
      print('Login response body: ${response.body}');
      
      return response;
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Failed to login user: $e');
    }
  }

  // getUserData method
  Future<http.Response> getUserData() async {
    String? accessToken = await getAccessToken();

    if (accessToken == null) {
      throw Exception("Access token is missing.");
    }

    final url = Uri.parse('${Constants.baseUrl}${Constants.userApiPath}/me');

    try {
      final response = await http.get(url,
          headers: _generateHeaders(accessToken: accessToken));
      return response; // Returning the http.Response
    } catch (e) {
      print("Error occurred: $e");
      throw Exception('Failed to fetch user data');
    }
  }

  // refreshAccessToken method
  Future<http.Response> refreshAccessToken() async {
    String? refreshToken = await getRefreshToken();

    if (refreshToken == null) {
      throw Exception("Refresh token is missing. Please log in again.");
    }

    final url =
        Uri.parse('${Constants.baseUrl}${Constants.userApiPath}/refresh-token');

    try {
      final response = await http.post(
        url,
        headers: _generateHeaders(),
        body: json.encode({'refreshToken': refreshToken}),
      );
      print(response.body);
      return response; // Returning the http.Response
    } catch (e) {
      print('Error during token refresh: $e');
      throw Exception('Failed to refresh access token');
    }
  }

  // New requestNewOTP method
  Future<http.Response> requestNewOTP(String email) async {
    final url = Uri.parse(
        '${Constants.baseUrl}${Constants.userApiPath}/new-otp/$email');

    try {
      final response = await http.get(url);
      return response; // Returning the http.Response
    } catch (e) {
      print('Error during OTP request: $e');
      throw Exception('Failed to request new OTP');
    }
  }

  // New verifyOTP method
  Future<http.Response> verifyOTP(String email, String otp) async {
    final url =
        Uri.parse('${Constants.baseUrl}${Constants.userApiPath}/verify-otp');

    // Prepare the body with email and OTP
    final body = json.encode({
      'email': email,
      'otp': otp,
    });

    try {
      final response = await http.post(
        url,
        headers: _generateHeaders(),
        body: body,
      );
      return response; // Returning the http.Response
    } catch (e) {
      print('Error during OTP verification: $e');
      throw Exception('Failed to verify OTP');
    }
  }

  Future<http.Response> resetForgetPassword(
      String email, String newPassword) async {
    final url = Uri.parse(
        '${Constants.baseUrl}${Constants.userApiPath}/reset-password');

    // Prepare the body with email and new password
    final body = json.encode({
      'email': email,
      'newPassword': newPassword,
    });

    try {
      final response = await http.post(
        url,
        headers: _generateHeaders(),
        body: body,
      );
      return response; // Returning the http.Response
    } catch (e) {
      print('Error during password reset: $e');
      throw Exception('Failed to reset password');
    }
  }

  // New updatePassword method
  Future<http.Response> updatePassword(
      String oldPassword, String newPassword) async {
    final url = Uri.parse(
        '${Constants.baseUrl}${Constants.userApiPath}/update-password');

    // Prepare the body with old and new passwords
    final body = json.encode({
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });

    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception("Access token is missing.");
      }

      final response = await http.post(
        url,
        headers: _generateHeaders(accessToken: accessToken),
        body: body,
      );

      return response; // Returning the http.Response
    } catch (e) {
      print('Error during password update: $e');
      throw Exception('Failed to update password');
    }
  }

  Future<http.Response> completeUserProfile({
    required String bio,
    required String cnic,
    required String gender,
    required int streetNo,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) async {
    final url = Uri.parse(
        '${Constants.baseUrl}${Constants.userApiPath}/complete-profile');
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception("Access token is missing.");
    }
    // Prepare the body with user profile data
    final body = json.encode({
      'bio': bio,
      'cnic': cnic,
      'gender': gender,
      'address': {
        'street_no': streetNo,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'location': '$city, $state, $country',
      }
    });

    try {
      final response = await http.patch(
        url,
        headers: _generateHeaders(accessToken: accessToken),
        body: body,
      );
      return response; // Return the http.Response object
    } catch (e) {
      print('Error completing profile: $e');
      throw Exception('Failed to complete profile');
    }
  }

  Future<http.Response> switchRole() async {
    final url =
        Uri.parse('${Constants.baseUrl}${Constants.userApiPath}/switch-role');
    final accessToken = await getAccessToken();

    if (accessToken == null) {
      throw Exception("Access token is missing.");
    }

    try {
      final response = await http.patch(
        url,
        headers: _generateHeaders(accessToken: accessToken),
      );
      return response; // Return the http.Response object
    } catch (e) {
      print('Error switching role: $e');
      throw Exception('Failed to switch role');
    }
  }

  // New logout method
  Future<http.Response> logout() async {
    final accessToken = await getAccessToken();

    if (accessToken == null) {
      throw Exception("Access token is missing.");
    }

    final url =
        Uri.parse('${Constants.baseUrl}${Constants.userApiPath}/logout');

    try {
      final response = await http.post(
        url,
        headers: _generateHeaders(accessToken: accessToken),
      );

      return response; // Returning the http.Response
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to log out');
    }
  }

  Future<String?> updateProfilePicture(String imagePath) async {
    final accessToken = await getAccessToken();

    if (accessToken == null) {
      throw Exception("Access token is missing.");
    }

    final url = Uri.parse(
        '${Constants.baseUrl}${Constants.userApiPath}/profile-picture');

    try {
      final request = http.MultipartRequest('PATCH', url)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..files.add(
          await http.MultipartFile.fromPath('profile_picture', imagePath),
        );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(responseData.body);

        if (data['success'] == true) {
          // Ensure correct access of the profile picture URL
          return data['data']['profile_picture'];
        } else {
          throw Exception(
              data['message'] ?? "Failed to update profile picture.");
        }
      } else {
        // Handle non-200 responses
        throw Exception(
            "Failed to update profile picture. Status code: ${response.statusCode}");
      }
    } catch (e) {
      // Log the error for debugging
      print("Error updating profile picture: $e");
      rethrow; // Rethrow to allow higher-level handling
    }
  }

  Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  Future<http.Response> sendFCMTokenToBackend() async {
    try {
      final String? deviceId = await getDeviceId();
      final accessToken = await getAccessToken();
      final fcmToken = await getFcmToken();
      final deviceName = Platform.isAndroid ? 'android' : 'ios';
      
      if (deviceId == null || fcmToken == null || accessToken == null) {
        throw Exception('Device ID, FCM token, or access token is missing.');
      }

      // Extract user ID from the access token
      final parts = accessToken.split('.');
      if (parts.length != 3) {
        throw Exception('Invalid access token format');
      }

      // Add padding to base64url string
      String normalize(String input) {
        var output = input.replaceAll('-', '+').replaceAll('_', '/');
        switch (output.length % 4) {
          case 0:
            break;
          case 2:
            output += '==';
            break;
          case 3:
            output += '=';
            break;
          default:
            throw Exception('Illegal base64url string');
        }
        return output;
      }

      final payload = json.decode(
        utf8.decode(
          base64Url.decode(
            normalize(parts[1])
          )
        )
      );
      print('Token payload: $payload');

      final userId = payload['userId'];
      if (userId == null) {
        throw Exception('User ID not found in access token');
      }

      // Construct the body with resolved values
      final body = {
        'fcm_token': fcmToken,
        'device_id': deviceId,
        'device_name': deviceName,
      };

      print('Sending FCM token with body: $body');

      // Use the correct endpoint for FCM token update
      final url = Uri.parse('${Constants.baseUrl}/api/auth/upsert-fcm-token');
      print('Making request to: $url');

      // Add user ID to headers
      final headers = {
        ..._generateHeaders(accessToken: accessToken),
        'user-id': userId.toString(),
      };
      print('Request headers: $headers');

      final response = await http.put(
        url,
        body: jsonEncode(body),
        headers: headers,
      );

      print('FCM token response status: ${response.statusCode}');
      print('FCM token response body: ${response.body}');
      print('FCM token response headers: ${response.headers}');

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update FCM token');
      }

      return response;
    } catch (e) {
      print('Error sending FCM token: $e');
      rethrow;
    }
  }

  Future<http.Response> fetchProfileCompletion() async {
    final url = Uri.parse(
        '${Constants.baseUrl}${Constants.userApiPath}/calculate-profile-completion');
    final accessToken = await getAccessToken();

    if (accessToken == null) {
      throw Exception("Access token is missing.");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch profile completion: $e');
    }
  }
}
