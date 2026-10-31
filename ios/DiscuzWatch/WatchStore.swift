import Combine
import Foundation
import WatchConnectivity

final class WatchStore: NSObject, ObservableObject, WCSessionDelegate {
  @Published private(set) var snapshot: WatchSnapshot?
  @Published private(set) var reachable = false
  @Published private(set) var refreshing: Set<String> = []
  @Published var feedback: String?
  private var lastAutomaticRefresh = Date.distantPast

  override init() {
    super.init()
    guard WCSession.isSupported() else { return }
    let session = WCSession.default
    session.delegate = self
    accept(session.receivedApplicationContext["snapshot"])
    session.activate()
  }

  private func accept(_ value: Any?) {
    guard let updated = WatchSnapshot.decode(value),
      updated.revision >= (snapshot?.revision ?? 0) else { return }
    snapshot = updated
  }

  func refresh(_ section: String = "threads", automatic: Bool = false) {
    guard WCSession.default.activationState == .activated else { return }
    if automatic {
      guard Date().timeIntervalSince(lastAutomaticRefresh) > 60 else { return }
      lastAutomaticRefresh = Date()
    }
    guard !refreshing.contains(section) else { return }
    guard WCSession.default.isReachable else {
      if !automatic { feedback = "Open DisFly on your iPhone, then try again." }
      return
    }
    refreshing.insert(section)
    WCSession.default.sendMessage(["command": "refresh", "section": section], replyHandler: { [weak self] reply in
      DispatchQueue.main.async {
        guard let self = self else { return }
        self.refreshing.remove(section)
        self.accept(reply["snapshot"])
        if reply["error"] != nil {
          self.feedback = "Open DisFly on your iPhone, then try again."
        }
      }
    }, errorHandler: { [weak self] _ in
      DispatchQueue.main.async {
        self?.refreshing.remove(section)
        if !automatic { self?.feedback = "Unable to connect to your iPhone." }
      }
    })
  }

  func openOnPhone(_ item: WatchItem, section: String, contextID: String) {
    guard WCSession.default.isReachable else {
      feedback = "Open DisFly on your iPhone, then try again."
      return
    }
    WCSession.default.sendMessage([
      "command": "openItem", "section": section, "id": item.id, "contextID": contextID,
    ], replyHandler: { [weak self] reply in
      DispatchQueue.main.async {
        self?.feedback = (reply["opened"] as? Bool == true)
          ? "Ready on your iPhone. Open DisFly to continue reading."
          : "The account or content changed. Refresh and try again."
      }
    }, errorHandler: { [weak self] _ in
      DispatchQueue.main.async { self?.feedback = "Unable to connect to your iPhone." }
    })
  }

  func readerRequest(_ command: String, item: WatchItem, section: String, contextID: String,
                     extra: [String: Any] = [:], completion: @escaping ([String: Any]) -> Void) {
    guard WCSession.default.isReachable else {
      completion(["error": "phone_unavailable"])
      return
    }
    var message: [String: Any] = [
      "command": command, "section": section, "id": item.id, "contextID": contextID,
    ]
    message.merge(extra) { _, new in new }
    WCSession.default.sendMessage(message, replyHandler: { reply in
      DispatchQueue.main.async { completion(reply) }
    }, errorHandler: { _ in
      DispatchQueue.main.async {
        completion(["error": command == "sendReply" ? "send_unknown" : "phone_unavailable"])
      }
    })
  }

  static func readerError(_ reply: [String: Any]) -> String {
    switch reply["error"] as? String {
    case "account_changed", "content_changed": return "The account or content changed. Refresh and try again."
    case "session_expired": return "Your session expired. Sign in again on your iPhone."
    case "send_unknown": return "Sending status is unknown. Refresh the conversation before trying again."
    case "send_rejected": return "Your forum rejected the reply. It may require verification on iPhone."
    case "reply_unavailable", "invalid_reply": return "Replying is unavailable. Check your account and forum permissions."
    default: return "Unable to load. Keep your paired iPhone nearby with DisFly running, then retry."
    }
  }

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState,
               error: Error?) {
    DispatchQueue.main.async { [weak self] in
      self?.reachable = session.isReachable
      self?.accept(session.receivedApplicationContext["snapshot"])
      if activationState == .activated { self?.refresh(automatic: true) }
    }
  }

  func sessionReachabilityDidChange(_ session: WCSession) {
    DispatchQueue.main.async { [weak self] in
      self?.reachable = session.isReachable
      if session.isReachable { self?.refresh(automatic: true) }
    }
  }

  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    DispatchQueue.main.async { [weak self] in self?.accept(applicationContext["snapshot"]) }
  }
}

struct WatchReadingBlock: Decodable, Identifiable {
  let id: String
  let author: String
  let body: String
}

struct WatchReadingPage: Decodable {
  let title: String
  let page: Int
  let part: Int
  let blocks: [WatchReadingBlock]
  let hasNextPart: Bool
  let hasNextPage: Bool
  let canReply: Bool

  static func decode(_ value: Any?) -> WatchReadingPage? {
    guard let value = value, JSONSerialization.isValidJSONObject(value),
      let data = try? JSONSerialization.data(withJSONObject: value) else { return nil }
    return try? JSONDecoder().decode(Self.self, from: data)
  }
}
