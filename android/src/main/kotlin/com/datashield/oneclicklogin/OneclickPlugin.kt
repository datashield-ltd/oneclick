package com.datashield.oneclicklogin

import android.annotation.SuppressLint
import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.datashield.oneclick.LoginManager
import com.datashield.oneclick.SDKCallback
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel.EventSink

/** OneclickPlugin */
class OneclickPlugin: FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel: EventChannel
  private val mainHandler = Handler(Looper.getMainLooper())
  private lateinit var context: Context
  private var sdkManager: LoginManager? = null
  private var eventSink: EventSink? = null


  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "oneclick")
    channel.setMethodCallHandler(this)
    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "oneclick_events")
    eventChannel.setStreamHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  @SuppressLint("DiscouragedApi")
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getSupportsOneClickLogin" -> {
        try {
          if (sdkManager == null) {
            result.success(false)
            return
          }
          Thread(Runnable {
            try {
              val isSupported = sdkManager?.supportsOneClickLogin ?: false
              mainHandler.post {
                result.success(isSupported)
              }
            } catch (e: Exception) {
              Log.e("OneclickPlugin", "Check Android support status failed in background thread: ${e.message}")
              mainHandler.post {
                result.success(false)
              }
            }
          }).start()
        } catch (e: Exception) {
          Log.e("OneclickPlugin", "Failed to start background thread: ${e.message}")
          result.success(false)
        }
      }
      "setLanguage" -> {
        try {
          val languageCode = call.argument<String>("languageCode") ?: ""
          LoginManager.setLanguage(languageCode)
          result.success(true)
        } catch (e: Exception) {
          Log.e("OneclickPlugin", "Set language failed: ${e.message}")
          result.success(false)
        }
      }
      "initSdk" -> {
        try {
          val token = call.argument<String>("token") ?: ""
          val ak = call.argument<String>("ak") ?: ""
          val sk = call.argument<String>("sk") ?: ""
          LoginManager.init(context, token, ak, sk)
          sdkManager = LoginManager.getInstance()
          result.success(true)
        } catch (e: Exception) {
          Log.e("OneclickPlugin", "SDK initialization failed: ${e.message}")
          result.success(false)
        }
      }
      "setLogo" -> {
        try {
          val logoResName = call.argument<String>("resName")
          if (logoResName.isNullOrEmpty()) {
            result.error("INVALID_ARGUMENTS", "resName is required", null)
            result.success(false)
          }
          @SuppressLint("DiscouragedApi")
          var resId = context.resources.getIdentifier(logoResName, "drawable", context.packageName)
          if (resId == 0) {
            resId = context.resources.getIdentifier(logoResName, "mipmap", context.packageName)
          }
          if (resId == 0) {
            result.error("INVALID_RESOURCE", "Drawable not found: $logoResName", null)
            result.success(false)
          }
          LoginManager.getInstance().setLogoResId(resId)
          result.success(true)
        } catch (e: Exception) {
          result.error("SET_LOGO_ERROR", e.message, null)
          result.success(false)
        }
      }
      "setCallback" -> {
        try {
          if (sdkManager != null) {
            sdkManager?.registerCallback(object : SDKCallback {
              override fun onSuccess(s: String?) {
                mainHandler.post {
                  eventSink?.success(mapOf(
                    "type" to "success",
                    "data" to s
                  ))
                }
              }

              override fun onFailure(error: String?) {
                eventSink?.success(mapOf(
                  "type" to "failure",
                  "error" to error
                ))
              }
            })
            result.success(true)
          } else {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
          }
        } catch (e: Exception) {
          Log.e("OneclickPlugin", "Register callback failed: \${e.message}")
          result.success(false)
        }
      }
      "startLogin" -> {
        try {
          if (sdkManager != null) {
            sdkManager?.startLogin()
            result.success(true)
          } else {
            result.error("NOT_INITIALIZED", "SDK not initialized", null)
          }
        } catch (e: Exception) {
          Log.e("OneclickPlugin", "Start login failed: ${e.message}")
          result.success(false)
        }
      }
      "showLogin" -> {
        if (sdkManager != null) {
          sdkManager?.registerCallback(object : SDKCallback {
            override fun onSuccess(s: String?) {
              Log.e("OneclickPlugin", "Login onSuccess: $s")
              mainHandler.post {
                eventSink?.success(mapOf(
                  "type" to "login_success",
                  "success" to true,
                  "data" to s
                ))
              }
            }

            override fun onFailure(code: String?) {
              Log.e("OneclickPlugin", "Login onFailure: $code")
              mainHandler.post {
                eventSink?.success(mapOf(
                  "type" to "login_failure",
                  "success" to false,
                  "code" to code
                ))
              }
            }
          })
          sdkManager?.startLogin()
          result.success(mapOf(
            "success" to true,
            "message" to "Login process started, listen for events for results"
          ))
        } else {
          throw Exception("SDK not initialized")
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    sdkManager = null
    eventSink = null
  }

  override fun onListen(arguments: Any?, events: EventSink?) {
    eventSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}
