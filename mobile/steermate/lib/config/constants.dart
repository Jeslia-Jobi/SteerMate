class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost
  static const String iosBaseUrl = 'http://localhost:8000'; // iOS simulator
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';
  
  // Alert Thresholds (can be overridden in settings)
  static const double hardBrakeThreshold = -4.0; // m/s²
  static const double harshAccelThreshold = 4.0; // m/s²
  static const double unsafeCurveThreshold = 3.0; // m/s²
  static const double overspeedMargin = 5.0; // km/h over limit
  
  // Sensor Settings
  static const int imuSampleRate = 50; // Hz
  static const int gpsSampleRate = 1; // Hz
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
