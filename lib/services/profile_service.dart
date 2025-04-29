import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String baseUrl =
      'http://mohamek-legel.runasp.net/api/ClientDashBoard/profile';
  static const String _tokenKey = 'auth_token';
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

  Future<Map<String, dynamic>> getProfile() async {
    try {
      print('Fetching profile from: $baseUrl');

      // Get the stored token
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login first.');
      }

      print('Using token: $token');

      final response = await http.get(
        Uri.parse(baseUrl), // Use baseUrl directly without appending /profile
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');

      if (_isHtmlResponse(response.body)) {
        // If we get a login page, try to extract the token from the response
        final tokenMatch = RegExp(
          'token["\']?\\s*:\\s*["\']([^"\']+)["\']',
        ).firstMatch(response.body);
        if (tokenMatch != null) {
          final newToken = tokenMatch.group(1);
          if (newToken != null) {
            await _saveToken(newToken);
            // Retry the request with the new token
            return getProfile();
          }
        }
        throw Exception(
          'Authentication required. The API returned a login page instead of JSON data.',
        );
      }

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          print('Decoded data: $data');
          return data;
        } catch (e) {
          print('Error decoding JSON: $e');
          throw Exception('Invalid JSON response from server');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication required. Please sign in first.');
      } else {
        throw Exception(
          'Failed to load profile: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in getProfile: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    try {
      print('Updating profile with data: $profileData');

      // Get the stored token
      final token = await _getToken();
      print(
        'Using token: ${token != null ? 'Token exists' : 'No token found'}',
      );

      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      );

      print('Update response status code: ${response.statusCode}');

      if (_isHtmlResponse(response.body)) {
        // If we get a login page, try to extract the token from the response
        final tokenMatch = RegExp(
          'token["\']?\\s*:\\s*["\']([^"\']+)["\']',
        ).firstMatch(response.body);
        if (tokenMatch != null) {
          final newToken = tokenMatch.group(1);
          if (newToken != null) {
            await _saveToken(newToken);
            // Retry the request with the new token
            return updateProfile(profileData);
          }
        }
        throw Exception(
          'Authentication required. The API returned a login page instead of JSON data.',
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication required. Please sign in first.');
      } else if (response.statusCode != 200) {
        throw Exception(
          'Failed to update profile: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in updateProfile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}
