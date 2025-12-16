class Constants {
  static const String baseUrl = String.fromEnvironment(
    'API_URL', 
    defaultValue: 'http://localhost:5000/api'
  );
  static const String appName = 'News Admin';
}
