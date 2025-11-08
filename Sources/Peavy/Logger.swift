import Foundation
import UIKit

internal class Logger {
    private let storage: Storage

    private var meta: Labels = [:]

    private lazy var logLabels: Labels = {
        var dict: Labels = [
            "platform": "ios",
            "platform-version": UIDevice.current.systemVersion,
            "device-model": UIDevice.current.modelName,
            "device-language": Locale.current.identifier.replacingOccurrences(of: "_", with: "-"),
            "device-screen-w": Int(UIScreen.main.bounds.width.rounded()),
            "device-screen-h": Int(UIScreen.main.bounds.height.rounded()),
        ]
        if let id = Bundle.main.bundleIdentifier {
            dict["app-id"] = id
        }
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            dict["app-version"] = version
        }
        if let code = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            dict["app-version-code"] = code
        }
        return dict
    }()
    
    private lazy var evLabels: Labels = {
        var dict: Labels = [
            "platform": "ios",
        ]
        if let id = Bundle.main.bundleIdentifier {
            dict["app-id"] = id
        }
        if let code = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            dict["app-version-code"] = code
        }
        return dict
    }()

    init(_ storage: Storage) {
        self.storage = storage

        if let defaultsData = UserDefaults.standard.data(forKey: "__peavy_meta"),
           let defaultsMeta = try? JSONSerialization.jsonObject(with: defaultsData) as? Labels {
            self.meta = defaultsMeta
        }
        
        resetSessionId()
    }

    func addMeta(_ meta: Labels) {
        self.meta.merge(meta, uniquingKeysWith: { $1 })
        if let data = try? JSONSerialization.data(withJSONObject: self.meta) {
            UserDefaults.standard.set(data, forKey: "__peavy_meta")
        }
    }

    func clearMeta() {
        self.meta.removeAll()
        UserDefaults.standard.removeObject(forKey: "__peavy_meta")
    }

    func log(_ entry: LogEntry) {
        if let print = try? Peavy.options.printToStdout, print {
            NSLog(entry.message)
        }
        
        Task(priority: .background) {
            await storage.storeEntry(build(entry))
        }
    }

    func build(_ entry: LogEntry) -> LogEntry {
        var entry = entry
        if entry.json["__peavy_type"] as? String == "event" {
            evLabels.forEach {
                entry.labels[$0] = $1
            }
        } else {
            logLabels.forEach {
                entry.labels[$0] = $1
            }
        }
        meta.forEach {
            entry.labels[$0] = $1
        }
        return entry
    }
    
    internal func resetSessionId() {
        let id = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(24)
        Debug.log("Reset session id to \(id)")
        logLabels["session-id"] = String(id)
        evLabels["session-id"] = String(id)
    }
}
