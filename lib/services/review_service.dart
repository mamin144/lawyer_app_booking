import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ReviewService {
  static const String baseUrl = 'http://mohamek-legel.runasp.net/api';
  static const String _tokenKey = 'auth_token';
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('ReviewService: SharedPreferences initialized');
  }

  // Get the stored token
  Future<String?> _getToken() async {
    final token = _prefs?.getString(_tokenKey);
    print(
        'ReviewService: Retrieved token: ${token != null ? 'Token exists' : 'No token found'}');
    print('ReviewService: Token value: $token');
    return token;
  }

  // Get reviews for a specific lawyer
  Future<List<dynamic>> getLawyerReviews(String lawyerId) async {
    try {
      print('ReviewService: Fetching reviews for lawyer ID: $lawyerId');

      // Get the stored token
      final token = await _getToken();
      if (token == null) {
        print('ReviewService: No authentication token found');
        throw Exception('No authentication token found. Please login first.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/Reviews/lawyer-reviews/$lawyerId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('ReviewService: Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final reviews = json.decode(response.body);
        print('ReviewService: Successfully fetched ${reviews.length} reviews');
        return reviews;
      } else {
        print('ReviewService: Failed to load reviews: ${response.body}');
        throw Exception('Failed to load reviews: ${response.statusCode}');
      }
    } catch (e) {
      print('ReviewService: Error in getLawyerReviews: $e');
      throw Exception('Failed to load reviews: $e');
    }
  }

  // Post a new review for a lawyer
  Future<Map<String, dynamic>> postReview({
    required String lawyerId,
    required double rating,
    required String comment,
  }) async {
    try {
      print('ReviewService: Posting review for lawyer ID: $lawyerId');

      final token = await _getToken();
      if (token == null) {
        print('ReviewService: No authentication token found');
        throw Exception('No authentication token found. Please login first.');
      }

      final clientId = await getCurrentUserId();

      if (lawyerId.isEmpty || comment.trim().isEmpty) {
        throw Exception('Lawyer ID and comment are required.');
      }

      print(
          'Sending review: lawyerId=$lawyerId, clientId=$clientId, rating=${rating.toInt()}, comment=$comment');

      final Map<String, dynamic> requestBody = {
        'LawyerId': lawyerId,
        'ClientId': clientId,
        'Rating': rating.toInt(),
        'Comment': comment,
      };
      print('Review request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/Review/create-review'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('ReviewService: Response status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = json.decode(response.body);
        print('ReviewService: Successfully posted review');
        print('Full review response: $result');
        return result;
      } else {
        print('ReviewService: Failed to post review: ${response.body}');
        throw Exception('فشل إضافة التقييم');
      }
    } catch (e) {
      print('ReviewService: Error in postReview: $e');
      throw Exception('فشل إضافة التقييم');
    }
  }

  Future<String?> getCurrentUserId() async {
    final token = await _getToken();
    if (token == null) return null;
    Map<String, dynamic> decoded = JwtDecoder.decode(token);
    // Adjust the key below to match your JWT structure
    return decoded[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        decoded['sub'] ??
        decoded['id'];
  }
}
