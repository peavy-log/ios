import Foundation

internal class Debug {
    static var enabled: Bool = false
    
    static func log(_ message: String) {
        guard enabled else { return }
        NSLog("[Peavy] \(message)")
    }
    
    static func warn(_ message: String) {
        guard enabled else { return }
        NSLog("[Peavy] WARNING: \(message)")
    }
}
