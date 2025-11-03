import Flutter
import UIKit
import DatashieldOneClick

public class OneclickPlugin: NSObject, FlutterPlugin {
  private var viewController: UIViewController? {
    return UIApplication.shared.keyWindow?.rootViewController
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
        name: "oneclick",
        binaryMessenger: registrar.messenger()
    )
    let instance = OneclickPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {

    case "setLogo":
      if let args = call.arguments as? [String: Any],
         let name = args["resName"] as? String,
         let logo = UIImage(named: name) {
        DSOCLoginManager.shared().setLogo(logo)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing resName", details: nil))
      }

    case "setLanguage":
      if let args = call.arguments as? [String: Any],
         let languageCode = args["languageCode"] as? String {
        DSOCLoginManager.shared().setLanguage(languageCode)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT",
                            message: "Missing or invalid languageCode",
                            details: nil))
      }

    case "register":
      if let args = call.arguments as? [String: Any],
         let token = args["token"] as? String,
         let ak = args["ak"] as? String,
         let sk = args["sk"] as? String {
        DSOCLoginManager.shared().register(withToken: token, ak: ak, sk: sk)
        result(nil)
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing token/ak/sk", details: nil))
      }

    case "getSupportsOneClickLogin":
      let supported = DSOCLoginManager.shared().supportsOneClickLogin
      result(supported)

    case "showLogin":
      DSOCLoginManager.shared().presentingViewController = viewController
      DSOCLoginManager.shared().showLogin { success, code, payload in
        var dict: [String: Any] = [
          "success": success,
          "code": code.rawValue
        ]
        if let payload = payload {
          for (k, v) in payload {
            dict[k as! String] = v
          }
        }
        result(dict)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
