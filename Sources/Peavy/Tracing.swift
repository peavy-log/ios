import Foundation

public struct PeavyTrace {
    let id: String
    let span: String
    let full: String
    let headers: [String: String]
}

public protocol PeavyTracing {
    func newTrace() -> PeavyTrace
    func newTrace(_ spanId: String) -> PeavyTrace
}

public class PeavyW3CTracing: PeavyTracing {
    public func newTrace() -> PeavyTrace { newTrace("") }
    public func newTrace(_ spanId: String) -> PeavyTrace {
        let traceId = UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "")
        var spanId = spanId
        if spanId.isEmpty {
            spanId = String(UUID().uuidString.lowercased().replacingOccurrences(of: "-", with: "").suffix(16))
        }
        let full = "00-\(traceId)-\(spanId)-03"
        
        return PeavyTrace(
            id: traceId,
            span: spanId,
            full: full,
            headers: ["traceparent": full]
        )
    }
}

public class PeavyGoogleTracing: PeavyW3CTracing {
    public override func newTrace(_ spanId: String) -> PeavyTrace {
        let trace = super.newTrace(spanId)
        return PeavyTrace(
            id: trace.id,
            span: trace.span,
            full: trace.full,
            headers: trace.headers.merging([
                "x-request-id": trace.id,
                "x-cloud-trace-context": "\(trace.id)/0;o=1"
            ]) { $1 }
        )
    }
}
