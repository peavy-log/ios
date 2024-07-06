import Foundation

extension Peavy {
    /// Opens a new HTTP trace, injecting headers into the `request` argument, and logs the request to Peavy.
    public static func logRequest(_ tracer: PeavyTracing, request: inout URLRequest, extra: Labels = [:]) {
        let trace = logRequest(tracer, url: request.url, method: request.httpMethod, extra: extra)
        for (key, val) in trace.headers {
            request.addValue(val, forHTTPHeaderField: key)
        }
    }

    /// Opens a new HTTP trace, logging the request to Peavy, and returns the trace struct.
    /// It is the callers responsibility to inject the trace headers into the request
    public static func logRequest(_ tracer: PeavyTracing, url: URL?, method: String?, extra: Labels = [:]) -> PeavyTrace {
        let trace = tracer.newTrace()
        logRequest(trace, url: url, method: method, extra: extra)
        return trace
    }

    /// Logs an HTTP trace to Peavy
    public static func logRequest(_ trace: PeavyTrace, url: URL?, method: String?, extra: Labels = [:]) {
        let http: Labels = [
            "side": "request",
            "url": url?.absoluteString ?? "",
            "method": method ?? "",
        ].merging(extra) { $1 }

        instance.logger.log(LogEntry(
            timestamp: Date(),
            level: .info,
            message: "HTTP Request \(method ?? "") \(url?.absoluteString ?? "")",
            error: nil,
            json: [
                "peavy/traceId": trace.id,
                "peavy/spanId": trace.span,
                "peavy/http": http as! Codable
            ]
        ))
    }
}
