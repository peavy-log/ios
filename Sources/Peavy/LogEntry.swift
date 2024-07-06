import Foundation

public typealias Labels = [String: Any]

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
            "timestamp": timestamp.formatted(.iso8601.time(includingFractionalSeconds: true)),
            "severity": level.stringValue,
            "message": message,
            "peavy/labels": labels,
        ].merging(json) { old, _ in old }

        if let error {
            json["error"] = String(describing: error)
        }

        return try JSONSerialization.data(withJSONObject: json)
    }
}
