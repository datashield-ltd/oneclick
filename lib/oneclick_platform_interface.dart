import 'dart:async';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'oneclick_method_channel.dart';

abstract class OneclickPlatform extends PlatformInterface {
  OneclickPlatform() : super(token: _token);

  static final Object _token = Object();

  static OneclickPlatform _instance = MethodChannelOneclick();
  static OneclickPlatform get instance => _instance;

  static set instance(OneclickPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Map<String, dynamic>> showLogin() {
    throw UnimplementedError('showLogin() has not been implemented.');
  }

  Future<void> initialize(String token, String ak, String sk) {
    throw UnimplementedError('init() has not been implemented.');
  }

  Future<bool> isSupport() {
    throw UnimplementedError('isSupport() has not been implemented.');
  }

  Future<void> setLogo(String resName) {
    throw UnimplementedError('setLogo() has not been implemented.');
  }

  Future<void> setLanguage(String languageCode) {
    throw UnimplementedError('startLogin() has not been implemented.');
  }

  /// Android get event stream
  Stream<Map<String, dynamic>> getEvents() {
    throw UnimplementedError('getEvents() has not been implemented.');
  }

  /// Get unified login result stream (Android and iOS)
  Stream<Map<String, dynamic>> get onLoginResult {
    throw UnimplementedError('onLoginResult has not been implemented.');
  }

  /// Stop listening
  void stopListening() {
    throw UnimplementedError('stopListening() has not been implemented.');
  }

  /// Release resources
  void dispose() {
    throw UnimplementedError('dispose() has not been implemented.');
  }
}