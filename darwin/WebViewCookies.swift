import Foundation
import WebKit
#if os(macOS)
import FlutterMacOS
#else
import Flutter
#endif

/// Uses the same default store as webview_flutter; never reads document.cookie.
final class WebViewCookies: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    #if os(macOS)
    let messenger = registrar.messenger
    #else
    let messenger = registrar.messenger()
    #endif
    let channel = FlutterMethodChannel(
      name: "com.kidozh.discuz_flutter/webview_cookies", binaryMessenger: messenger)
    registrar.addMethodCallDelegate(WebViewCookies(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let store = WKWebsiteDataStore.default().httpCookieStore
    if call.method == "clearCookies" {
      store.getAllCookies { cookies in
        let group = DispatchGroup()
        for cookie in cookies {
          group.enter()
          store.delete(cookie) { group.leave() }
        }
        group.notify(queue: .main) { result(nil) }
      }
      return
    }
    guard call.method == "getCookies" || call.method == "setCookies" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard let args = call.arguments as? [String: Any],
          let rawURL = args["url"] as? String,
          let url = URL(string: rawURL), let host = url.host?.lowercased(),
          url.scheme == "https" || url.scheme == "http" else {
      result(FlutterError(code: "invalid_url", message: "An HTTP(S) URL is required", details: nil))
      return
    }
    if call.method == "getCookies" {
      store.getAllCookies { cookies in
        let path = url.path.isEmpty ? "/" : url.path
        let rows: [[String: Any]] = cookies.compactMap { cookie in
          let domain = cookie.domain.lowercased().trimmingCharacters(in: CharacterSet(charactersIn: "."))
          let cookiePath = cookie.path.isEmpty ? "/" : cookie.path
          let domainMatches = host == domain || host.hasSuffix("." + domain)
          let pathMatches = path == cookiePath ||
            (path.hasPrefix(cookiePath) &&
              (cookiePath.hasSuffix("/") || path.dropFirst(cookiePath.count).hasPrefix("/")))
          guard domainMatches, pathMatches, !cookie.isSecure || url.scheme == "https" else {
            return nil
          }
          var row: [String: Any] = [
            "name": cookie.name, "value": cookie.value, "domain": cookie.domain,
            "path": cookie.path, "secure": cookie.isSecure, "httpOnly": cookie.isHTTPOnly,
          ]
          if let expiry = cookie.expiresDate {
            row["expiresAt"] = Int64(expiry.timeIntervalSince1970 * 1000)
          }
          return row
        }
        result(rows)
      }
    } else {
      guard let headers = args["cookies"] as? [String] else {
        result(FlutterError(code: "invalid_cookies", message: "Cookie headers are required", details: nil))
        return
      }
      let group = DispatchGroup()
      for header in headers {
        for cookie in HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": header], for: url) {
          group.enter()
          store.setCookie(cookie) { group.leave() }
        }
      }
      group.notify(queue: .main) { result(nil) }
    }
  }
}
