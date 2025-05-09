import Flutter
import UIKit
import in_app_purchase_storekit

let appGroupID = "group.com.ellipsoid.tagi"

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.ellipsoid.tagi/share", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call, result) in
      let userDefaults = UserDefaults(suiteName: appGroupID)

      switch call.method {
      case "getSharedData":
        // share extension에서 유저측으로 공유 정보 넘기기 위한 메소드
        if let items = userDefaults?.array(forKey: "sharedItems") as? [[String: String]] {
          result(items)
          userDefaults?.removeObject(forKey: "sharedItems")
          userDefaults?.synchronize()
        } else {
          result([])
        }

      case "saveTags":
        // share extension에 user tags 보여주기 위한 메소드
        guard let args = call.arguments as? [String: Any],
              let tags = args["tags"] as? [String] else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for saveTags", details: nil))
          return
        }

        userDefaults?.set(tags, forKey: "user_tags")
        userDefaults?.synchronize()
        result(true)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}