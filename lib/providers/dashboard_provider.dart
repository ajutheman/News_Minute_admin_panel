import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class DashboardProvider with ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _data;
  String? _error;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get data => _data;
  String? get error => _error;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/analytics/dashboard'));

      if (response.statusCode == 200) {
        _data = json.decode(response.body);
      } else {
        _error = 'Failed to load stats';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
