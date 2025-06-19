import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfileService {
  static const String _baseUrl = 'http://mohamek-legel.runasp.net/api';
  static const String _clientProfileUrl = '$_baseUrl/ClientDashBoard/profile';
  static const String _lawyerProfileUrl = '$_baseUrl/LawyerDashBoard/profile';
  static const String _clientUpdateProfileUrl =
      '$_baseUrl/ClientDashBoard/update-profile';
  static const String _lawyerUpdateProfileUrl =
      '$_baseUrl/LawyerDashBoard/update-profile';
  static const String _tokenKey = 'auth_token';
  static const String _userTypeKey = 'user_type';
  static SharedPreferences? _prefs;

  // Add public static method to initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Add this method to check if the response is HTML
  bool _isHtmlResponse(String response) {
    return response.trim().toLowerCase().startsWith('<!doctype html') ||
        response.trim().toLowerCase().startsWith('<html');
  }

  // Get the stored token
  Future<String?> _getToken() async {
    return _prefs?.getString(_tokenKey);
  }

  // Store the token
  Future<void> _saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  Future<String?> _getUserType() async {
    return _prefs?.getString(_userTypeKey);
  }

  Future<void> saveUserType(String userType) async {
    await _prefs?.setString(_userTypeKey, userType);
  }

  // Add this method to check current user role
  Future<String> getCurrentUserRole() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/Account/current-user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final role = data['role'] ?? ''; // adjust based on actual API response
        await saveUserType(role.toLowerCase()); // save the role
        return role.toLowerCase();
      } else {
        throw Exception('Failed to get user role: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting user role: $e');
      throw Exception('Failed to get user role');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final userType = await _getUserType();
      final baseUrl =
          userType == 'lawyer' ? _lawyerProfileUrl : _clientProfileUrl;
      print('Fetching profile from: $baseUrl');

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getProfile: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final userType = await _getUserType();
      final baseUrl = userType == 'lawyer'
          ? _lawyerUpdateProfileUrl
          : _clientUpdateProfileUrl;
      print('Updating profile at: $baseUrl');

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      );

      print('Update profile response status code: ${response.statusCode}');
      print('Update profile response body: ${response.body}');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<String> getCurrentUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return '';
    Map<String, dynamic> decoded = JwtDecoder.decode(token);
    print('Decoded JWT: $decoded');
    return decoded[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        '';
  }

  Future<bool> createLawyerDescription(
      Map<String, dynamic> descriptionData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // First check if the lawyer description already exists
      bool exists = false;
      try {
        final existingData = await getLawyerDescription();
        exists = existingData != null;
      } catch (e) {
        // Ignore errors and assume it doesn't exist
      }

      // Choose the appropriate endpoint based on whether the description exists
      final url = exists
          ? '$_baseUrl/LawyerDescription/update-lawyer-description'
          : '$_baseUrl/LawyerDescription/create-lawyer-description';

      print('${exists ? "Updating" : "Creating"} lawyer description at: $url');
      print('Payload: $descriptionData');

      final response = exists
          ? await http.put(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode(descriptionData),
            )
          : await http.post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode(descriptionData),
            );

      print('Lawyer description response status: ${response.statusCode}');
      print('Lawyer description response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Failed to ${exists ? "update" : "create"} lawyer description: ${response.statusCode}');
      }
    } catch (e) {
      print('Error with lawyer description: $e');
      throw Exception('Failed to save lawyer description: $e');
    }
  }

  Future<Map<String, dynamic>?> getLawyerDescription() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final url = '$_baseUrl/LawyerDescription/get-lawyer-description';
      print('Getting lawyer description from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Get lawyer description response status: ${response.statusCode}');
      print('Get lawyer description response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // Description doesn't exist yet
        return null;
      } else {
        throw Exception(
            'Failed to get lawyer description: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting lawyer description: $e');
      throw Exception('Failed to get lawyer description: $e');
    }
  }

  Future<Map<String, dynamic>?> getDescriptionByLawyerId(
      String lawyerId) async {
    try {
      final url =
          '$_baseUrl/LawyerDescription/get-description-throw-lawyer?lawyerId=$lawyerId';
      print('Getting lawyer description by ID from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print(
          'Get lawyer description by ID response status: ${response.statusCode}');
      print('Get lawyer description by ID response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // Description doesn't exist yet
        return null;
      } else {
        throw Exception(
            'Failed to get lawyer description by ID: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting lawyer description by ID: $e');
      throw Exception('Failed to get lawyer description by ID: $e');
    }
  }
}
