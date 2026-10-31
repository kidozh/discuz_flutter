import Flutter
import WatchConnectivity

/// WCSession owns delivery of the latest snapshot, including when the watch
/// is temporarily disconnected. Flutter owns authentication and API requests.
final class AppleWatchBridge: NSObject, FlutterPlugin, WCSessionDelegate {
  private let channel: FlutterMethodChannel
  private var snapshot: [String: Any]?
  private var dartReady = false

  private init(channel: FlutterMethodChannel) {
    self.channel = channel
    super.init()
    if WCSession.isSupported() {
      WCSession.default.delegate = self
      WCSession.default.activate()
    }
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.kidozh.discuz_flutter/apple_watch", binaryMessenger: registrar.messenger())
    let bridge = AppleWatchBridge(channel: channel)
    registrar.addMethodCallDelegate(bridge, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ready":
      dartReady = true
      result(WCSession.isSupported() && WCSession.default.isWatchAppInstalled)
    case "publishSnapshot":
      guard let value = call.arguments as? [String: Any],
        JSONSerialization.isValidJSONObject(value),
        let data = try? JSONSerialization.data(withJSONObject: value), data.count < 60_000
      else {
        result(FlutterError(code: "invalid_snapshot", message: nil, details: nil))
        return
      }
      snapshot = value
      publish()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func publish() {
    guard WCSession.isSupported(), let snapshot = snapshot else { return }
    let session = WCSession.default
    guard session.activationState == .activated, session.isPaired,
      session.isWatchAppInstalled else { return }
    do {
      try session.updateApplicationContext(["snapshot": snapshot])
    } catch {
      // Keep the newest value to retry after session activation/state changes.
      NSLog("Apple Watch snapshot delivery is unavailable")
    }
  }

  private func watchStateChanged() {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.publish()
      if self.dartReady {
        self.channel.invokeMethod("watchStateChanged", arguments: WCSession.default.isWatchAppInstalled)
      }
    }
  }

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
               error: Error?) {
    if activationState == .activated { watchStateChanged() }
  }

  func sessionWatchStateDidChange(_ session: WCSession) { watchStateChanged() }
  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) { session.activate() }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any],
               replyHandler: @escaping ([String: Any]) -> Void) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self, self.dartReady,
        let command = message["command"] as? String,
        ["refresh", "openItem", "loadDetail", "sendReply"].contains(command) else {
        replyHandler(["error": "phone_unavailable"])
        return
      }
      self.channel.invokeMethod(command, arguments: message) { value in
        if let snapshot = value as? [String: Any], command == "refresh" {
          replyHandler(["snapshot": snapshot])
        } else if ["loadDetail", "sendReply"].contains(command),
          let payload = value as? [String: Any], JSONSerialization.isValidJSONObject(payload),
          let data = try? JSONSerialization.data(withJSONObject: payload), data.count < 60_000 {
          replyHandler(payload)
        } else if let opened = value as? Bool, command == "openItem", opened {
          replyHandler(["opened": true])
        } else {
          replyHandler(["error": "phone_unavailable"])
        }
      }
    }
  }
}
