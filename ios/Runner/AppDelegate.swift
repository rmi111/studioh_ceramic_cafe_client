import Flutter
import UIKit
import FirebaseMessaging
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase is initialized by the Flutter plugin, but ensure it's ready
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    // Register with APNs for remote notifications
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)

    // Must come AFTER plugin registration. flutter_local_notifications registers after
    // firebase_messaging and claims UNUserNotificationCenter.delegate, which stops
    // firebase_messaging receiving foreground pushes — onMessage never fires on iOS.
    // Reclaiming it for FlutterAppDelegate (which firebase_messaging swizzles) restores it.
    UNUserNotificationCenter.current().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Forward APNs token to Firebase Messaging
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
