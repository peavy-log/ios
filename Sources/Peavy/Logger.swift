import Foundation
import UIKit

internal class Logger {
    private let storage: Storage

    internal var meta: Labels = [:]

    private lazy var labels: Labels = {
        [
            "platform": "ios",
            "platform-version": UIDevice.current.systemVersion,
            "app-id": Bundle.main.bundleIdentifier,
            "app-version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            "app-version-code": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
            "device-model": UIDevice.current.model,
            "device-language": Locale.current.identifier,
            "device-screen-w": UIScreen.main.bounds.width,
            "device-screen-h": UIScreen.main.bounds.height,
        ]
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
