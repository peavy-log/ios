import Foundation

public typealias Labels = [String: Codable]

internal struct LogEntry {
    let timestamp: Date
    let level: LogLevel
    let message: String
    let error: Error?

    var labels: Labels = [:]
    var json: Labels = [:]

    internal func toJson() throws -> Data {
        var message = message
        if message.isEmpty {
            message = level.stringValue
        }

        var json: [String: Any] = [
            "timestamp": timestamp.formatted(.iso8601),
            "severity": level.stringValue,
            "message": message,
            "peavy/labels": labels,
        ].merging(json) { old, _ in old }

        if let error {
            json["error"] = error.localizedDescription
        }

        return try JSONSerialization.data(withJSONObject: json)
    }
}
