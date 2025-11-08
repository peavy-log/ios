import Foundation

public enum EventType {
    case state
    case action
    
    public var stringValue: String {
        switch self {
        case .state: "state"
        case .action: "action"
        }
    }
}
