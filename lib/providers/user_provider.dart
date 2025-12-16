import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class UserProvider with ChangeNotifier {
  List<dynamic> _users = [];
  bool _isLoading = false;

  List<dynamic> get users => _users;
  bool get isLoading => _isLoading;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/users'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _users = json.decode(response.body);
      }
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser(String id, Map<String, dynamic> data) async {
    final token = await _getToken();
    try {
      final response = await http.patch(
        Uri.parse('${Constants.baseUrl}/users/$id'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        await fetchUsers();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> deleteUser(String id) async {
    final token = await _getToken();
    try {
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}/users/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        await fetchUsers();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }
}
