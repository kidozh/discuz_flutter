import Foundation
import SwiftUI
import Translation
import NaturalLanguage
#if os(iOS)
import Flutter
import UIKit
#else
import FlutterMacOS
import AppKit
#endif

public class ApplePostTranslationPlugin: NSObject, FlutterPlugin {
    private var cleanup: (() -> Void)?
    #if os(macOS)
    private weak var flutterView: NSView?
    #endif

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(iOS)
        let messenger = registrar.messenger()
        #else
        let messenger = registrar.messenger
        #endif
        let channel = FlutterMethodChannel(name: "com.kidozh.discuz_flutter/translation", binaryMessenger: messenger)
        let plugin = ApplePostTranslationPlugin()
        #if os(macOS)
        plugin.flutterView = registrar.view
        #endif
        registrar.addMethodCallDelegate(plugin, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 18.0, macOS 15.0, *) else {
            result(FlutterError(code: "translation_unavailable", message: "Update the system to use Apple Translation.", details: nil))
            return
        }
        Task { @MainActor in
            if call.method == "languages" {
                let availability: LanguageAvailability
                if #available(iOS 26.4, macOS 26.4, *) {
                    availability = LanguageAvailability(preferredStrategy: .lowLatency)
                } else {
                    availability = LanguageAvailability()
                }
                let args = call.arguments as? [String: Any]
                let displayLocale = (args?["displayLocale"] as? String).map { Locale(identifier: $0) } ?? Locale.current
                let languages = await availability.supportedLanguages
                result(languages.map { language in
                    let id = language.maximalIdentifier
                    return ["id": id, "name": displayLocale.localizedString(forIdentifier: id) ?? id]
                }.sorted { $0["name"]! < $1["name"]! })
                return
            }
            if call.method == "detectLanguage" {
                guard let args = call.arguments as? [String: Any], let text = args["text"] as? String else {
                    result(FlutterError(code: "invalid_arguments", message: nil, details: nil)); return
                }
                let recognizer = NLLanguageRecognizer()
                recognizer.processString(text)
                guard let source = recognizer.dominantLanguage else {
                    result(FlutterError(code: "translation_source_undetected",
                        message: "There is not enough text to identify the source language.", details: nil)); return
                }
                result(source.rawValue)
                return
            }
            guard call.method == "translate" else { result(FlutterMethodNotImplemented); return }
            #if targetEnvironment(simulator)
            result(FlutterError(code: "translation_simulator", message: "Apple Translation requires a physical device.", details: nil))
            return
            #else
            guard let args = call.arguments as? [String: Any],
                  let text = args["text"] as? String,
                  let target = args["target"] as? String,
                  let sourceIdentifier = args["source"] as? String else {
                result(FlutterError(code: "invalid_arguments", message: nil, details: nil)); return
            }
            guard cleanup == nil else {
                result(FlutterError(code: "translation_busy", message: nil, details: nil)); return
            }
            let language = Locale.Language(identifier: target)
            // Detect once from the post, rather than asking Translation to identify
            // each short HTML node. Only a substantial, confident mixed-language
            // passage overrides that document source.
            let letterCount = text.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count
            guard letterCount > 0 else { result(text); return }
            var source = Locale.Language(identifier: sourceIdentifier)
            if letterCount >= 40 {
                let recognizer = NLLanguageRecognizer()
                recognizer.processString(text)
                if let candidate = recognizer.languageHypotheses(withMaximum: 1).first,
                   candidate.value >= 0.85 {
                    source = Locale.Language(identifier: candidate.key.rawValue)
                }
            }
            if source.languageCode == language.languageCode && source.script == language.script {
                result(text); return
            }
            let view = PostTranslationTask(text: text, source: source, target: language) { [weak self] response in
                self?.cleanup?()
                self?.cleanup = nil
                switch response {
                case .success(let value): result(value)
                case .failure(let error):
                    result(FlutterError(code: "translation_failed", message: error.localizedDescription, details: nil))
                }
            }
            #if os(iOS)
            guard var parent = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows }).first(where: { $0.isKeyWindow })?.rootViewController else {
                result(FlutterError(code: "translation_no_window", message: nil, details: nil)); return
            }
            while let presented = parent.presentedViewController { parent = presented }
            let host = UIHostingController(rootView: view)
            parent.addChild(host)
            host.view.backgroundColor = .clear
            host.view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            parent.view.addSubview(host.view)
            host.didMove(toParent: parent)
            cleanup = { [weak host] in
                host?.willMove(toParent: nil)
                host?.view.removeFromSuperview()
                host?.removeFromParent()
            }
            #else
            // Use the window belonging to this Flutter engine. A language sheet
            // or another application may own the key window when a chunk starts.
            guard let parent = (flutterView?.window ?? NSApp.mainWindow)?.contentViewController else {
                result(FlutterError(code: "translation_no_window", message: nil, details: nil)); return
            }
            let host = NSHostingController(rootView: view)
            parent.addChild(host)
            host.view.frame = NSRect(x: 0, y: 0, width: 1, height: 1)
            parent.view.addSubview(host.view)
            cleanup = { [weak host] in
                host?.view.removeFromSuperview()
                host?.removeFromParent()
            }
            #endif
            #endif
        }
    }
}

@available(iOS 18.0, macOS 15.0, *)
private struct PostTranslationTask: View {
    let text: String
    let source: Locale.Language
    let target: Locale.Language
    let completion: (Result<String, Error>) -> Void
    @State private var completed = false

    private var configuration: TranslationSession.Configuration {
        var config = TranslationSession.Configuration(source: source, target: target)
        if #available(iOS 26.4, macOS 26.4, *) { config.preferredStrategy = .lowLatency }
        return config
    }

    var body: some View {
        Color.clear.translationTask(configuration) { session in
            guard !completed else { return }
            do {
                let response = try await session.translate(text)
                completed = true
                completion(.success(response.targetText))
            } catch {
                completed = true
                completion(.failure(error))
            }
        }
    }
}
