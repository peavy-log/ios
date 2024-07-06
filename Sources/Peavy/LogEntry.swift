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

        let timeFormatter = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
        var json: [String: Any] = [
            "timestamp": timestamp.formatted(timeFormatter),
            "severity": level.stringValue,
            "message": message,
            "peavy/labels": labels,
        ].merging(json) { old, _ in old }

        if let error {
            json["error"] = "\(error)"
        }

        return try JSONSerialization.data(withJSONObject: json)
    }
}
