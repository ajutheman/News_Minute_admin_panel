import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class CategoryProvider with ChangeNotifier {
  List<dynamic> _categories = [];
  bool _isLoading = false;

  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/categories'));
      if (response.statusCode == 200) {
        _categories = json.decode(response.body);
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addCategory(Map<String, dynamic> categoryData) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(categoryData),
      );
      if (response.statusCode == 201) {
        await fetchCategories();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> categoryData) async {
    final token = await _getToken();
    try {
      final response = await http.patch(
        Uri.parse('${Constants.baseUrl}/categories/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(categoryData),
      );
      if (response.statusCode == 200) {
        await fetchCategories();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> deleteCategory(String id) async {
    final token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}/categories/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _categories.removeWhere((cat) => cat['_id'] == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
