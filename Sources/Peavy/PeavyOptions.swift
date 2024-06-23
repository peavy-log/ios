import Foundation

public struct PeavyOptions {
    let endpoint: URL
    let logLevel: LogLevel
    let printToStdout: Bool
    let debug: Bool
    
    public init(
        endpoint: URL,
        logLevel: LogLevel,
        printToStdout: Bool = false,
        debug: Bool = false
    ) {
        self.endpoint = endpoint
        self.logLevel = logLevel
        self.printToStdout = printToStdout
        self.debug = debug
    }
}
