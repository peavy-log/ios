import Foundation

public enum EventResult {
    case success
    case failure
    case timeout
    case cancelled
    
    public var stringValue: String {
        switch self {
        case .success: "success"
        case .failure: "failure"
        case .timeout: "timeout"
        case .cancelled: "cancelled"
        }
    }
}
