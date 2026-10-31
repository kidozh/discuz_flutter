import SwiftUI

@main
struct DiscuzWatchApp: App {
  @StateObject private var store = WatchStore()
  @Environment(\.scenePhase) private var scenePhase

  var body: some Scene {
    WindowGroup {
      WatchHomeView()
        .environmentObject(store)
        .alert("DisFly", isPresented: Binding(
          get: { store.feedback != nil }, set: { if !$0 { store.feedback = nil } }
        )) {
          Button("OK", role: .cancel) { store.feedback = nil }
        } message: {
          Text(LocalizedStringKey(store.feedback ?? ""))
        }
        .onChange(of: scenePhase) { _, phase in
          if phase == .active { store.refresh(automatic: true) }
        }
    }
  }
}

struct WatchHomeView: View {
  @EnvironmentObject private var store: WatchStore

  var body: some View {
    NavigationStack {
      List {
        if let snapshot = store.snapshot, snapshot.hasSite {
          Section {
            VStack(alignment: .leading, spacing: 4) {
              Text(snapshot.siteName).font(.headline)
              Text(snapshot.signedIn ? snapshot.username : String(localized: "Guest"))
                .font(.caption).foregroundStyle(.secondary)
            }
            .privacySensitive()
          }
          if snapshot.sessionExpired {
            Text("Your session expired. Sign in again on your iPhone.")
          } else {
            if snapshot.signedIn {
              Section("Inbox") {
                NavigationLink {
                  WatchItemList(section: "notifications", title: "Notifications")
                } label: {
                  inboxLabel("Notifications", icon: "bell.badge", count: snapshot.notices)
                }
                NavigationLink {
                  WatchItemList(section: "messages", title: "Private messages")
                } label: {
                  inboxLabel("Private messages", icon: "bubble.left.and.bubble.right", count: snapshot.messagesUnread)
                }
              }
            }
            Section("Hot threads") {
              WatchRows(section: "threads", snapshot: snapshot)
            }
          }
          Section {
            if snapshot.updatedAt > 0 {
              VStack(alignment: .leading) {
                Text("Last synced").font(.caption2)
                Text(Date(timeIntervalSince1970: Double(snapshot.updatedAt) / 1000), style: .relative)
                  .font(.caption2).foregroundStyle(.secondary)
              }
            }
            if !store.reachable { Text("Showing saved content").font(.caption2) }
          }
        } else {
          ContentUnavailableView("Your forum, at a glance", systemImage: "bubble.left.and.text.bubble.right",
            description: Text("Open DisFly on your iPhone and select a forum to get started."))
        }
      }
      .navigationTitle("DisFly")
      .toolbar { refreshButton("threads") }
    }
    // Account changes also dismiss any previously visible private previews.
    .id("\(store.snapshot?.contextID ?? "")-\(store.snapshot?.sessionExpired ?? false)")
  }

  private func inboxLabel(_ title: LocalizedStringKey, icon: String, count: Int) -> some View {
    HStack {
      Label(title, systemImage: icon)
      Spacer(minLength: 4)
      Text("\(count)").monospacedDigit().foregroundStyle(.tint).privacySensitive()
    }
  }

  @ToolbarContentBuilder
  private func refreshButton(_ section: String) -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      WatchRefreshButton(section: section)
    }
  }
}

struct WatchItemList: View {
  @EnvironmentObject private var store: WatchStore
  let section: String
  let title: LocalizedStringKey

  var body: some View {
    List {
      if let snapshot = store.snapshot {
        WatchRows(section: section, snapshot: snapshot)
      }
      if section == "notifications" {
        Text("Opening notifications may mark them as read on your forum.")
          .font(.caption2).foregroundStyle(.secondary)
      }
    }
    .navigationTitle(title)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) { WatchRefreshButton(section: section) }
    }
    .task { store.refresh(section) }
  }
}

struct WatchRows: View {
  @EnvironmentObject private var store: WatchStore
  let section: String
  let snapshot: WatchSnapshot

  var body: some View {
    if snapshot.errors[section] != nil {
      Text("Couldn't refresh. Try again on your iPhone.")
        .font(.caption).foregroundStyle(.orange)
    }
    let items = snapshot.items(in: section)
    if items.isEmpty {
      if store.refreshing.contains(section) {
        ProgressView()
      } else if snapshot.loadedSections.contains(section) {
        Text("Nothing here yet").font(.caption).foregroundStyle(.secondary)
      } else {
        Text("Open DisFly on your iPhone, then refresh.")
          .font(.caption).foregroundStyle(.secondary)
      }
    }
    ForEach(items) { item in
      NavigationLink {
        WatchItemDetail(item: item, section: section, contextID: snapshot.contextID)
      } label: {
        VStack(alignment: .leading, spacing: 5) {
          HStack(alignment: .firstTextBaseline, spacing: 4) {
            if item.unread { Image(systemName: "circle.fill").font(.system(size: 6)).foregroundStyle(.tint) }
            Text(item.title.isEmpty ? String(localized: "Notification") : item.title)
              .font(.headline).lineLimit(3)
          }
          if section != "threads", !item.body.isEmpty {
            Text(item.body).font(.caption).foregroundStyle(.secondary).lineLimit(2)
          } else if !item.subtitle.isEmpty {
            Text(item.subtitle).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
          }
        }
        .privacySensitive()
      }
    }
  }
}

struct WatchItemDetail: View {
  @EnvironmentObject private var store: WatchStore
  let item: WatchItem
  let section: String
  let contextID: String
  @State private var reading: WatchReadingPage?
  @State private var blocks: [WatchReadingBlock] = []
  @State private var loading = false
  @State private var error: String?
  @State private var composing = false

  var body: some View {
    List {
      Section {
        Text(reading?.title.isEmpty == false ? reading!.title : item.title)
          .font(.headline)
        if let error = error {
          Text(LocalizedStringKey(error)).font(.caption).foregroundStyle(.orange)
          Button("Retry") { load(page: reading?.page ?? 1, part: reading?.part ?? 0) }
        }
        if reading == nil && !item.body.isEmpty { Text(item.body) }
        ForEach(blocks) { block in
          VStack(alignment: .leading, spacing: 6) {
            if !block.author.isEmpty {
              Text(block.author).font(.caption).foregroundStyle(.secondary)
            }
            Text(block.body).font(.body)
          }
        }
        if loading { ProgressView() }
        if let reading = reading {
          if reading.hasNextPart {
            Button("More text") { load(page: reading.page, part: reading.part + 1, append: true) }
              .disabled(loading)
          } else if reading.hasNextPage {
            Button(LocalizedStringKey(section == "messages" ? "Older messages" : "Next replies")) {
              load(page: reading.page + 1, part: 0)
            }.disabled(loading)
          }
          if reading.page > 1 {
            Button("Previous page") { load(page: reading.page - 1, part: 0) }.disabled(loading)
          }
          if reading.canReply {
            Button(LocalizedStringKey(section == "messages" ? "Send a message" : "Reply")) { composing = true }
              .buttonStyle(.borderedProminent)
          }
        }
      }.privacySensitive()
      Section {
        Button("Refresh content") { load(page: reading?.page ?? 1, part: 0) }.disabled(loading)
        Button {
          store.openOnPhone(item, section: section, contextID: contextID)
        } label: {
          Label("Continue on iPhone", systemImage: "iphone")
        }
      }
    }
    .id(reading?.page ?? 1)
    .navigationTitle(LocalizedStringKey(section == "messages" ? "Conversation" : "Read on Watch"))
    .toolbar {
      if reading?.canReply == true {
        ToolbarItem(placement: .topBarTrailing) {
          Button { composing = true } label: { Image(systemName: "arrowshape.turn.up.left") }
            .accessibilityLabel("Reply")
        }
      }
    }
    .task { if reading == nil { load(page: 1, part: 0) } }
    .sheet(isPresented: $composing) {
      WatchReplyComposer(item: item, section: section, contextID: contextID) {
        load(page: 1, part: 0)
      }.environmentObject(store)
    }
  }

  private func load(page: Int, part: Int, append: Bool = false) {
    guard !loading else { return }
    loading = true
    error = nil
    store.readerRequest("loadDetail", item: item, section: section, contextID: contextID,
                        extra: ["page": page, "part": part]) { reply in
      loading = false
      guard store.snapshot?.contextID == contextID else { return }
      guard let result = WatchReadingPage.decode(reply["detail"]) else {
        error = WatchStore.readerError(reply)
        return
      }
      reading = result
      if append {
        let existing = Set(blocks.map(\.id))
        blocks.append(contentsOf: result.blocks.filter { !existing.contains($0.id) })
      } else {
        blocks = result.blocks
      }
    }
  }
}

struct WatchReplyComposer: View {
  @EnvironmentObject private var store: WatchStore
  @Environment(\.dismiss) private var dismiss
  let item: WatchItem
  let section: String
  let contextID: String
  let onSent: () -> Void
  @State private var draft = ""
  @State private var sending = false
  @State private var confirmSend = false
  @State private var error: String?
  @State private var uncertain = false

  var body: some View {
    NavigationStack {
      Form {
        Text(item.title).font(.caption).privacySensitive()
        TextField("Write a reply", text: $draft).disabled(sending).privacySensitive()
        Text("Use dictation or the system keyboard. Up to 1,000 characters.")
          .font(.caption2).foregroundStyle(.secondary)
        if let error = error {
          Text(LocalizedStringKey(error)).font(.caption).foregroundStyle(.orange)
        }
        if uncertain {
          Button("Return and check content") { dismiss() }
        }
        Button("Send") { confirmSend = true }
          .disabled(sending || uncertain || draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.unicodeScalars.count > 1000)
        if sending { ProgressView() }
      }
      .navigationTitle("Reply")
      .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.disabled(sending) } }
      .confirmationDialog("Send this reply?", isPresented: $confirmSend, titleVisibility: .visible) {
        Button("Send") { send() }
        Button("Cancel", role: .cancel) {}
      } message: { Text(draft) }
    }
  }

  private func send() {
    guard !sending && !uncertain else { return }
    sending = true
    error = nil
    store.readerRequest("sendReply", item: item, section: section, contextID: contextID,
                        extra: ["text": draft, "requestID": UUID().uuidString]) { reply in
      sending = false
      guard store.snapshot?.contextID == contextID else { dismiss(); return }
      if reply["sent"] as? Bool == true {
        draft = ""
        dismiss()
        store.feedback = "Reply sent."
        onSent()
      } else {
        error = WatchStore.readerError(reply)
        uncertain = reply["error"] as? String == "send_unknown"
      }
    }
  }
}

struct WatchRefreshButton: View {
  @EnvironmentObject private var store: WatchStore
  let section: String

  var body: some View {
    Button {
      store.refresh(section)
    } label: {
      if store.refreshing.contains(section) { ProgressView() }
      else { Image(systemName: "arrow.clockwise") }
    }
    .disabled(store.refreshing.contains(section))
    .accessibilityLabel("Refresh")
  }
}
