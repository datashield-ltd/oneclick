import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'oneclick_platform_interface.dart';

class MethodChannelOneclick extends OneclickPlatform {
  static const MethodChannel _channel = MethodChannel('oneclick');
  static const EventChannel _eventChannel = EventChannel('oneclick_events');

  StreamSubscription<Map<String, dynamic>>? _loginSubscription;
  final StreamController<Map<String, dynamic>> _loginResultController =
  StreamController<Map<String, dynamic>>.broadcast();

  @override
  Future<Map<String, dynamic>> showLogin() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('showLogin');

      if (Platform.isAndroid) {
        // Android only returns whether the login process was successfully initiated, actual login results are delivered via event stream
        // Automatically start listening for login events
        _startListeningEvents();

        if (result != null) {
          return {
            'success': result.containsKey('success') ? result['success'] : false,
            'message': result.containsKey('message') ? result['message'] : ''
          };
        }
        return {'success': false, 'error': 'Unknown error'};

      } else if (Platform.isIOS) {
        // iOS directly returns login results and also sends them to the stream
        final loginData = Map<String, dynamic>.from(result!);

        // Also send iOS results to the unified stream
        if (!_loginResultController.isClosed) {
          _loginResultController.add(loginData);
        }

        // Also return original data for backward compatibility
        return loginData;
      }

      return {'success': false, 'error': 'Unknown platform'};
    } catch (e) {
      // Errors are also sent to the stream
      final errorResult = {'success': false, 'error': e.toString()};
      if (!_loginResultController.isClosed) {
        _loginResultController.add(errorResult);
      }
      return errorResult;
    }
  }

  @override
  Future<void> initialize(String token, String ak, String sk) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('initSdk', {
        'token': token,
        'ak': ak,
        'sk': sk,
      });
    } else if (Platform.isIOS) {
      await _channel.invokeMethod('register', {
        'token': token,
        'ak': ak,
        'sk': sk,
      });
    }
  }

  @override
  Future<bool> isSupport() async {
    final result = await _channel.invokeMethod<bool>('getSupportsOneClickLogin');
    return result ?? false;
  }

  @override
  Future<void> setLogo(String resName) async {
    await _channel.invokeMethod('setLogo', {'resName': resName});
  }

  @override
  Future<void> setLanguage(String languageCode) async {
    await _channel.invokeMethod('setLanguage', {
      'languageCode': languageCode
    });
  }

  @override
  Stream<Map<String, dynamic>> getEvents() {
    if (Platform.isIOS) {
      return const Stream.empty();
    }
    return _eventChannel.receiveBroadcastStream().map((dynamic event) {
      Map<String, dynamic> result = Map<String, dynamic>.from(event as Map);
      if (result['type'] == 'login_success' &&
          result.containsKey('data') && result['data'] is String) {
        try {
          final jsonData = _decodeJsonString(result['data'] as String);
          if (jsonData != null) {
            result['token'] = jsonData['token'];
            result['phone_number'] = jsonData['phone_number'];
          }
        } catch (e) {
          print('Failed to parse event data: $e');
        }
      }

      return result;
    });
  }

  /// Get unified login result stream (Android and iOS)
  @override
  Stream<Map<String, dynamic>> get onLoginResult => _loginResultController.stream;

  /// Internal method: Start listening for login events (Android only)
  void _startListeningEvents() {
    if (Platform.isIOS) return;

    // Cancel previous subscription
    _loginSubscription?.cancel();

    _loginSubscription = getEvents().listen((event) {
      // Forward events to the unified result stream
      if (!_loginResultController.isClosed) {
        _loginResultController.add(event);
      }
    }, onError: (error) {
      if (!_loginResultController.isClosed) {
        _loginResultController.add({
          'success': false,
          'type': 'error',
          'error': error.toString()
        });
      }
    });
  }

  /// Stop listening for events
  @override
  void stopListening() {
    _loginSubscription?.cancel();
    _loginSubscription = null;
  }

  /// Release resources
  @override
  void dispose() {
    stopListening();
    _loginResultController.close();
  }

  Map<String, dynamic>? _decodeJsonString(String jsonStr) {
    try {
      final dynamic result = jsonDecode(jsonStr);
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
    } catch (e) {
      print('_decodeJsonString failed: $e');
    }
    return null;
  }
}