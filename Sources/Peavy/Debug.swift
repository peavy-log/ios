import Foundation

internal class Debug {
    static var enabled: Bool = false
    
    static func log(_ message: String) {
        guard enabled else { return }
        NSLog("[Peavy] \(message)")
    }
    
    static func warn(_ message: String) {
        Task {
            guard Peavy.isSetup else { return }

            var entry = LogEntry(
                timestamp: Date(),
                level: .warning,
                message: "[Peavy] \(message)",
                error: nil,
                labels: ["peavy/internal": "true"]
            )
            do {
                entry = Peavy.instance.logger.build(entry)
                try await Peavy.instance.push.direct(entry.toJson())
            } catch {
                // Not much we can do at this point. Give it to regular logger
                Peavy.instance.logger.log(entry)
            }
        }

        guard enabled else { return }
        NSLog("[Peavy] WARNING: \(message)")
    }
}
