import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  // General Settings
  bool _isDarkMode = true;
  bool _useMetricUnits = true; // km/h vs mph
  bool _onDeviceML = true;

  // Alert Settings
  double _hardBrakeThreshold = AppConstants.hardBrakeThreshold;
  double _harshAccelThreshold = AppConstants.harshAccelThreshold;
  double _unsafeCurveThreshold = AppConstants.unsafeCurveThreshold;
  double _overspeedMargin = AppConstants.overspeedMargin;
  bool _audioAlertsEnabled = true;
  bool _hapticAlertsEnabled = true;

  // Privacy Settings
  bool _shareAnonymousData = false;
  bool _uploadVideoRoi = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get useMetricUnits => _useMetricUnits;
  bool get onDeviceML => _onDeviceML;
  double get hardBrakeThreshold => _hardBrakeThreshold;
  double get harshAccelThreshold => _harshAccelThreshold;
  double get unsafeCurveThreshold => _unsafeCurveThreshold;
  double get overspeedMargin => _overspeedMargin;
  bool get audioAlertsEnabled => _audioAlertsEnabled;
  bool get hapticAlertsEnabled => _hapticAlertsEnabled;
  bool get shareAnonymousData => _shareAnonymousData;
  bool get uploadVideoRoi => _uploadVideoRoi;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isDarkMode = await _storage.getSetting<bool>('dark_mode') ?? true;
    _useMetricUnits = await _storage.getSetting<bool>('metric_units') ?? true;
    _onDeviceML = await _storage.getSetting<bool>('on_device_ml') ?? true;
    _hardBrakeThreshold = await _storage.getSetting<double>('hard_brake_threshold') ?? AppConstants.hardBrakeThreshold;
    _harshAccelThreshold = await _storage.getSetting<double>('harsh_accel_threshold') ?? AppConstants.harshAccelThreshold;
    _unsafeCurveThreshold = await _storage.getSetting<double>('unsafe_curve_threshold') ?? AppConstants.unsafeCurveThreshold;
    _overspeedMargin = await _storage.getSetting<double>('overspeed_margin') ?? AppConstants.overspeedMargin;
    _audioAlertsEnabled = await _storage.getSetting<bool>('audio_alerts') ?? true;
    _hapticAlertsEnabled = await _storage.getSetting<bool>('haptic_alerts') ?? true;
    _shareAnonymousData = await _storage.getSetting<bool>('share_data') ?? false;
    _uploadVideoRoi = await _storage.getSetting<bool>('upload_roi') ?? false;
    notifyListeners();
  }

  // General Settings Setters
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _storage.saveSetting('dark_mode', value);
    notifyListeners();
  }

  Future<void> setMetricUnits(bool value) async {
    _useMetricUnits = value;
    await _storage.saveSetting('metric_units', value);
    notifyListeners();
  }

  Future<void> setOnDeviceML(bool value) async {
    _onDeviceML = value;
    await _storage.saveSetting('on_device_ml', value);
    notifyListeners();
  }

  // Alert Settings Setters
  Future<void> setHardBrakeThreshold(double value) async {
    _hardBrakeThreshold = value;
    await _storage.saveSetting('hard_brake_threshold', value);
    notifyListeners();
  }

  Future<void> setHarshAccelThreshold(double value) async {
    _harshAccelThreshold = value;
    await _storage.saveSetting('harsh_accel_threshold', value);
    notifyListeners();
  }

  Future<void> setUnsafeCurveThreshold(double value) async {
    _unsafeCurveThreshold = value;
    await _storage.saveSetting('unsafe_curve_threshold', value);
    notifyListeners();
  }

  Future<void> setOverspeedMargin(double value) async {
    _overspeedMargin = value;
    await _storage.saveSetting('overspeed_margin', value);
    notifyListeners();
  }

  Future<void> setAudioAlerts(bool value) async {
    _audioAlertsEnabled = value;
    await _storage.saveSetting('audio_alerts', value);
    notifyListeners();
  }

  Future<void> setHapticAlerts(bool value) async {
    _hapticAlertsEnabled = value;
    await _storage.saveSetting('haptic_alerts', value);
    notifyListeners();
  }

  // Privacy Settings Setters
  Future<void> setShareAnonymousData(bool value) async {
    _shareAnonymousData = value;
    await _storage.saveSetting('share_data', value);
    notifyListeners();
  }

  Future<void> setUploadVideoRoi(bool value) async {
    _uploadVideoRoi = value;
    await _storage.saveSetting('upload_roi', value);
    notifyListeners();
  }

  // Speed conversion helpers
  String formatSpeed(double speedMs) {
    if (_useMetricUnits) {
      return '${(speedMs * 3.6).toStringAsFixed(0)} km/h';
    } else {
      return '${(speedMs * 2.237).toStringAsFixed(0)} mph';
    }
  }

  String formatDistance(double distanceM) {
    if (_useMetricUnits) {
      if (distanceM < 1000) {
        return '${distanceM.toStringAsFixed(0)} m';
      }
      return '${(distanceM / 1000).toStringAsFixed(1)} km';
    } else {
      final miles = distanceM / 1609.34;
      return '${miles.toStringAsFixed(1)} mi';
    }
  }
}
