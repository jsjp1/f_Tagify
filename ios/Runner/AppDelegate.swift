import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.ellipsoid.tagi/share", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call, result) in
      let userDefaults = UserDefaults(suiteName: "group.com.ellipsoid.tagi")

      switch call.method {
      case "getSharedData":
        if let items = userDefaults?.array(forKey: "sharedItems") as? [[String: String]] {
          result(items)
          userDefaults?.removeObject(forKey: "sharedItems")
          userDefaults?.synchronize()
        } else {
          result([])
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}