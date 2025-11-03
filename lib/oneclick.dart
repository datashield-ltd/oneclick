import 'dart:async';
import 'oneclick_platform_interface.dart';

class Oneclick {
  static final OneclickPlatform _platform = OneclickPlatform.instance;

  /// Show one-click login
  static Future<Map<String, dynamic>> showLogin() => _platform.showLogin();

  /// Initialize SDK
  static Future<void> initialize({
    required String token,
    required String ak,
    required String sk,
  }) => _platform.initialize(token, ak, sk);

  /// Check if one-click login is supported
  static Future<bool> isSupport() => _platform.isSupport();

  /// Set Logo
  static Future<void> setLogo(String resName) => _platform.setLogo(resName);

  /// Set language
  static Future<void> setLanguage(String languageCode) =>
      _platform.setLanguage(languageCode);

  /// Android get original event stream
  static Stream<Map<String, dynamic>> getEvents() => _platform.getEvents();

  /// Get unified login result stream (recommended, supports Android and iOS)
  static Stream<Map<String, dynamic>> get onLoginResult =>
      _platform.onLoginResult;

  /// Get platform instance (for calling dispose, etc.)
  static OneclickPlatform get instance => _platform;
}