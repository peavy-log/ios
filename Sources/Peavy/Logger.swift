import Foundation
import UIKit

internal class Logger {
    private let storage: Storage

    internal var meta: Labels = [:]

    private lazy var labels: Labels = {
        var dict: Labels = [
            "platform": "ios",
            "platform-version": UIDevice.current.systemVersion,
            "device-model": UIDevice.current.model,
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

    init(_ storage: Storage) {
        self.storage = storage
    }
    
    func log(_ entry: LogEntry) {
        if Peavy.options.printToStdout {
            NSLog(entry.message)
        }
        
        Task(priority: .background) {
            var entry = entry
            entry.labels.merge(labels, uniquingKeysWith: { $1 })
            entry.labels.merge(meta, uniquingKeysWith: { $1 })
            
            await storage.storeEntry(entry)
        }
    }
}
