import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AdProvider with ChangeNotifier {
  List<dynamic> _ads = [];
  bool _isLoading = false;

  List<dynamic> get ads => _ads;
  bool get isLoading => _isLoading;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchAds() async {
    _isLoading = true;
    notifyListeners();
    final token = await _getToken(); // Admin route for ALL ads
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/ads'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _ads = json.decode(response.body);
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addAd(Map<String, dynamic> data) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/ads'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(data),
      );
      if (response.statusCode == 201) {
        await fetchAds();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  // Add update and delete similarly
  Future<bool> updateAd(String id, Map<String, dynamic> data) async {
      final token = await _getToken();
      try {
        final response = await http.patch(
          Uri.parse('${Constants.baseUrl}/ads/$id'),
           headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
           body: json.encode(data),
        );
        if (response.statusCode == 200) {
          await fetchAds();
          return true;
        }
      } catch (e) { print(e); }
      return false;
  }

  Future<bool> deleteAd(String id) async {
      final token = await _getToken();
      try {
        final response = await http.delete(
          Uri.parse('${Constants.baseUrl}/ads/$id'),
           headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          await fetchAds();
          return true;
        }
      } catch (e) { print(e); }
      return false;
  }
}
