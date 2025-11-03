import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oneclick/oneclick.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = 'Not logged in';
  bool _supported = false;
  bool _loading = false;
  bool _checking = false;
  StreamSubscription<Map<String, dynamic>>? subscription;
  Timer? _checkTimer;
  int _retryCount = 0;
  static const int maxRetries = 5;
  static const Duration retryInterval = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    /**
     * Android & iOS Unified Integration Process (Optimized)
     * 1. initialize initialization
     * 2. After initialization is complete, check if one-click login is supported (with retry mechanism)
     * 3. Listen to the unified login result stream onLoginResult
     * 4. showLogin display one-click login
     */
    initOneclick();
    startListeningEvents();
  }

  /// Initialize Oneclick SDK
  Future<void> initOneclick() async {
    try {
      setState(() {
        _loading = true;
        _result = 'Initializing...';
      });

      await Oneclick.initialize(
        token: "wKrHRIt0pJQjk-p-sssssssssssss",
        ak: "2QIROmR1Z9oONaq4aYVXRla9cky2227o",
        sk: "gjBrFbrgSS4cK9IfCoXd4V7imj74UG2uaCfE5cD_IPRGLDG7SKxhWL1DDmc_O3Qi",
      );

      await Oneclick.setLogo("ic_launcher");
      await Oneclick.setLanguage("en");

      setState(() {
        _result = 'Initialization successful, checking support...';
      });

      // After initialization is complete, delay checking if one-click login is supported
      // Give the native SDK some time to complete initialization
      await Future.delayed(const Duration(milliseconds: 300));

      // Start periodic detection
      _startCheckingSupport();

    } on PlatformException catch (e) {
      setState(() {
        _result = 'Initialization failed: ${e.message}';
        _loading = false;
      });
    }
  }

  /// Start periodic checking for one-click login support
  void _startCheckingSupport() {
    _checking = true;
    _retryCount = 0;
    _checkSupportStatus();
  }

  /// Check support status (with retry mechanism)
  Future<void> _checkSupportStatus() async {
    if (!mounted || !_checking) return;

    try {
      bool supported = await Oneclick.isSupport();
      if (supported) {
        // Support detected, stop retrying
        setState(() {
          _supported = true;
          _loading = false;
          _checking = false;
          _result = '✅ Detection complete, current device supports one-click login';
        });
        _checkTimer?.cancel();
      } else if (_retryCount < maxRetries) {
        // Support not yet detected, continue retrying
        _retryCount++;
        setState(() {
          _result = 'Checking... (${_retryCount}/$maxRetries)';
        });

        _checkTimer = Timer(retryInterval, () {
          _checkSupportStatus();
        });
      } else {
        // Reached maximum retry attempts, consider not supported
        setState(() {
          _supported = false;
          _loading = false;
          _checking = false;
          _result = '❌ Current environment does not support one-click login';
        });
      }
    } catch (e) {
      print('Error checking support status: $e');
      if (_retryCount < maxRetries) {
        _retryCount++;
        _checkTimer = Timer(retryInterval, () {
          _checkSupportStatus();
        });
      } else {
        setState(() {
          _supported = false;
          _loading = false;
          _checking = false;
          _result = '❌ Detection failed, defaulting to not supported';
        });
      }
    }
  }

  /// Start listening for login results (unified handling for Android and iOS)
  void startListeningEvents() {
    subscription?.cancel();

    // Use unified onLoginResult stream
    subscription = Oneclick.onLoginResult.listen((event) {
      print('Received login result: $event');

      if (event["type"] == "login_success" && event["success"] == true) {
        // Android login success
        setState(() {
          _result = "✅ Login successful\n📱 Phone number: ${event["phone_number"] ?? ''}\n🔑 Token: ${event["token"] ?? ''}";
          _loading = false;
        });
      } else if (event["type"] == "login_failure" && event["success"] == false) {
        // Android login failure
        final errorCode = event["code"] ?? 'UNKNOWN_ERROR';
        Fluttertoast.showToast(
          msg: "Login failed, error code: $errorCode",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        setState(() {
          _result = "❌ Login failed\ncode=$errorCode";
          _loading = false;
        });
      } else if (event["success"] == true && !event.containsKey("type")) {
        // iOS login success (no type field)
        setState(() {
          _result = "✅ Login successful\n📱 Phone number: ${event["phone_number"] ?? ''}\n🔑 Token: ${event["token"] ?? ''}";
          _loading = false;
        });
      } else if (event["success"] == false && !event.containsKey("type")) {
        // iOS login failure
        final errorCode = event["code"] ?? 'UNKNOWN_ERROR';
        Fluttertoast.showToast(
          msg: "Login failed, error code: $errorCode",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        setState(() {
          _result = "❌ Login failed\nError code: ${event["code"] ?? ''}\n${event["message"] ?? ''}";
          _loading = false;
        });
      }
    }, onError: (error) {
      setState(() {
        _result = "❌ Failed to listen for login results: $error";
        _loading = false;
      });
    });
  }

  /// Initiate one-click login (unified handling for Android and iOS)
  Future<void> doLogin() async {
    try {
      setState(() {
        _loading = true;
        _result = 'Starting login...';
      });

      final result = await Oneclick.showLogin();

      // Check if login process was successfully initiated
      if (result["success"] != true) {
        setState(() {
          _result = "❌ Failed to start login: ${result["error"] ?? result["message"] ?? 'Unknown error'}";
          _loading = false;
        });
      }
      // If launched successfully, the actual login result will be returned through the onLoginResult stream
      // Both Android and iOS will be handled by the listener in startListeningEvents

    } on PlatformException catch (e) {
      setState(() {
        _result = 'Exception: ${e.message}';
        _loading = false;
      });
    }
  }

  /// Manual recheck (optional feature)
  Future<void> recheckSupport() async {
    setState(() {
      _loading = true;
      _result = 'Rechecking...';
    });

    _startCheckingSupport();
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    subscription?.cancel();
    Oneclick.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oneclick SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OneClick SDK Example'),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.phone_android, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 16),
                Text(
                  _supported
                      ? "✅ Current device supports one-click login"
                      : _checking
                      ? "🔄 Checking..."
                      : "❌ Current environment does not support one-click login",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30),
                _loading || _checking
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  strokeWidth: 3,
                )
                    : _supported
                    ? ElevatedButton.icon(
                  onPressed: doLogin,
                  icon: const Icon(Icons.login),
                  label: const Text("Initiate One-Click Login"),
                )
                    : OutlinedButton.icon(
                  onPressed: recheckSupport,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Recheck"),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    _result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}