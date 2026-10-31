import Foundation

struct WatchItem: Decodable, Identifiable {
  let id: Int
  let title: String
  let subtitle: String
  let body: String
  let unread: Bool
  let replies: Int
}

struct WatchSnapshot: Decodable {
  let schema: Int
  let revision: Int64
  let contextID: String
  let siteName: String
  let username: String
  let hasSite: Bool
  let signedIn: Bool
  let sessionExpired: Bool
  let updatedAt: Int64
  let notices: Int
  let messagesUnread: Int
  let loadedSections: [String]
  let errors: [String: String]
  let threads: [WatchItem]
  let notifications: [WatchItem]
  let messages: [WatchItem]

  func items(in section: String) -> [WatchItem] {
    switch section {
    case "notifications": return notifications
    case "messages": return messages
    default: return threads
    }
  }

  static func decode(_ value: Any?) -> WatchSnapshot? {
    guard let value = value, JSONSerialization.isValidJSONObject(value),
      let data = try? JSONSerialization.data(withJSONObject: value),
      let snapshot = try? JSONDecoder().decode(WatchSnapshot.self, from: data),
      snapshot.schema == 1 else { return nil }
    return snapshot
  }
}
