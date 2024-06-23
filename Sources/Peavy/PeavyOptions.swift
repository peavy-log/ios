import Foundation

public struct PeavyOptions {
    let endpoint: URL
    let logLevel: LogLevel
    let enableCrashReporting: Bool
    let printToStdout: Bool
    let debug: Bool
    
    public init(
        endpoint: URL,
        logLevel: LogLevel,
        enableCrashReporting: Bool = true,
        printToStdout: Bool = false,
        debug: Bool = false
    ) {
        self.endpoint = endpoint
        self.logLevel = logLevel
        self.enableCrashReporting = enableCrashReporting
        self.printToStdout = printToStdout
        self.debug = debug
    }
}
