import Foundation

struct VerbosityError: Error {
    
}

enum LogLevel: RawRepresentable, Comparable {
    init?(rawValue: Int) {
        switch rawValue {
        case 1: self = .trace
        case 2: self = .debug
        case 3: self = .info
        case 4: self = .warning
        case 5: self = .error
        default: return nil
        }
    }
    
    case trace
    case debug
    case info
    case warning
    case error
    
    var rawValue: Int {
        switch self {
        case .trace: 1
        case .debug: 2
        case .info: 3
        case .warning: 4
        case .error: 5
        }
    }
    
    var stringValue: String {
        switch self {
        case .trace: "trace"
        case .debug: "debug"
        case .info: "info"
        case .warning: "warning"
        case .error: "error"
        }
    }
}
