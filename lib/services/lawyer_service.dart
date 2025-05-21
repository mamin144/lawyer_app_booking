import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LawyerService {
  static const String baseUrl =
      'http://mohamek-legel.runasp.net/api/LayOut/get-all-lawyers';
  static const String _tokenKey = 'auth_token';
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('SharedPreferences initialized');
  }

  // Get the stored token
  Future<String?> _getToken() async {
    final token = _prefs?.getString(_tokenKey);
    print(
      'Retrieved token: ${token != null ? 'Token exists' : 'No token found'}',
    );
    return token;
  }

  // Check if response is HTML
  bool _isHtmlResponse(String response) {
    return response.trim().toLowerCase().startsWith('<!doctype html') ||
        response.trim().toLowerCase().startsWith('<html');
  }

  Future<List<dynamic>> getAllLawyers() async {
    try {
      print('Fetching lawyers from: $baseUrl');

      // Get the stored token
      final token = await _getToken();
      if (token == null) {
        print('No authentication token found');
        throw Exception('No authentication token found. Please login first.');
      }

      print('Making API request with token...');
      final response = await http.get(
        Uri.parse(
          '$baseUrl?pageSize=100&pageNumber=1',
        ), // Request more lawyers per page
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (_isHtmlResponse(response.body)) {
        print('Received HTML response instead of JSON');
        throw Exception(
          'Authentication required. The API returned a login page instead of JSON data.',
        );
      }

      if (response.statusCode == 200) {
        try {
          final dynamic decoded = json.decode(response.body);
          print('Full API response:');
          print(decoded);

          // Check if the response has a data property
          if (decoded is Map && decoded.containsKey('data')) {
            final List<dynamic> data = List<dynamic>.from(decoded['data']);
            print('Successfully decoded ${data.length} lawyers');
            print(
              'First lawyer data: ${data.isNotEmpty ? data[0] : 'No lawyers found'}',
            );
            return data;
          } else if (decoded is List) {
            // If the response is directly a list
            final List<dynamic> data = List<dynamic>.from(decoded);
            print('Successfully decoded ${data.length} lawyers');
            print(
              'First lawyer data: ${data.isNotEmpty ? data[0] : 'No lawyers found'}',
            );
            return data;
          } else {
            print('Unexpected response format');
            throw Exception('Unexpected response format from server');
          }
        } catch (e) {
          print('Error decoding JSON: $e');
          throw Exception('Invalid JSON response from server');
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        print('Authentication error: ${response.statusCode}');
        throw Exception('Authentication required. Please sign in first.');
      } else {
        print('Server error: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to load lawyers: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in getAllLawyers: $e');
      throw Exception('Failed to load lawyers: $e');
    }
  }
}
