import Flutter
import UIKit
import Darwin

// Copy into the ISOLATED iOS test build only. Production AppDelegate is unchanged.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var thermalChannel: FlutterMethodChannel?
  private var thermalObserver: NSObjectProtocol?
  private var worstThermal = ProcessInfo.processInfo.thermalState.rawValue
  private var previousIdleTimer = false
  private var previousBatteryMonitoring = false
  private var lastProbeLog: TimeInterval = 0

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "Issue12ThermalProbe") else { return }
    let channel = FlutterMethodChannel(name: "discuz.issue12/thermal", binaryMessenger: registrar.messenger())
    thermalChannel = channel
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      switch call.method {
      case "begin":
        guard Bundle.main.bundleIdentifier == "com.kidozh.discuz-flutter.perftest" else {
          result(FlutterError(code: "wrong_bundle", message: "Use the isolated test app", details: nil))
          return
        }
        self.previousIdleTimer = UIApplication.shared.isIdleTimerDisabled
        self.previousBatteryMonitoring = UIDevice.current.isBatteryMonitoringEnabled
        UIApplication.shared.isIdleTimerDisabled = true
        UIDevice.current.isBatteryMonitoringEnabled = true
        self.worstThermal = ProcessInfo.processInfo.thermalState.rawValue
        self.thermalObserver = NotificationCenter.default.addObserver(
          forName: ProcessInfo.thermalStateDidChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
          self?.worstThermal = max(self?.worstThermal ?? 0, ProcessInfo.processInfo.thermalState.rawValue)
        }
        result(self.snapshot())
      case "snapshot": result(self.snapshot())
      case "saveReport":
        do {
          guard let json = call.arguments as? String else {
            result(FlutterError(code: "invalid_report", message: "Expected JSON string", details: nil))
            return
          }
          let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
          let name = "issue12-thermal-\(Int(Date().timeIntervalSince1970)).json"
          try Data(json.utf8).write(to: documents.appendingPathComponent(name), options: .atomic)
          result("Documents/" + name)
        } catch {
          result(FlutterError(code: "save_failed", message: error.localizedDescription, details: nil))
        }
      case "end":
        UIApplication.shared.isIdleTimerDisabled = self.previousIdleTimer
        UIDevice.current.isBatteryMonitoringEnabled = self.previousBatteryMonitoring
        if let observer = self.thermalObserver { NotificationCenter.default.removeObserver(observer) }
        self.thermalObserver = nil
        result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    }
  }

  private func snapshot() -> [String: Any] {
    let process = ProcessInfo.processInfo
    let state = process.thermalState
    worstThermal = max(worstThermal, state.rawValue)
    let name: String
    switch state {
    case .nominal: name = "nominal"
    case .fair: name = "fair"
    case .serious: name = "serious"
    case .critical: name = "critical"
    @unknown default: name = "unknown"
    }
    if process.systemUptime - lastProbeLog >= 10 {
      lastProbeLog = process.systemUptime
      NSLog("ISSUE12_PROBE thermal=%@ worst=%ld", name, worstThermal)
    }
    let battery: String
    switch UIDevice.current.batteryState {
    case .unplugged: battery = "unplugged"
    case .charging: battery = "charging"
    case .full: battery = "full"
    default: battery = "unknown"
    }
    let screen = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first?.screen
    var usage = rusage()
    let usageAvailable = getrusage(RUSAGE_SELF, &usage) == 0
    let cpuUser = Double(usage.ru_utime.tv_sec) + Double(usage.ru_utime.tv_usec) / 1_000_000
    let cpuSystem = Double(usage.ru_stime.tv_sec) + Double(usage.ru_stime.tv_usec) / 1_000_000
    #if targetEnvironment(simulator)
    let simulator = true
    #else
    let simulator = false
    #endif
    return ["appIdentifier": Bundle.main.bundleIdentifier ?? "", "isSimulator": simulator,
      "os": process.operatingSystemVersionString, "thermal": name,
      "thermalRaw": state.rawValue, "worstThermalRaw": worstThermal,
      "batteryLevel": UIDevice.current.batteryLevel, "batteryState": battery,
      "brightness": screen?.brightness ?? -1, "maximumFramesPerSecond": screen?.maximumFramesPerSecond ?? 0,
      "lowPower": process.isLowPowerModeEnabled, "uptimeSeconds": process.systemUptime,
      "cpuTimeAvailable": usageAvailable, "cpuUserSeconds": cpuUser, "cpuSystemSeconds": cpuSystem]
  }
}
