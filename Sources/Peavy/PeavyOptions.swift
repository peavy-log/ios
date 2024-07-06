import Foundation

/// Initialisation options for Peavy
public struct PeavyOptions {
    /// The remote endpoint to push logs to.
    /// Should be a full URL.
    let endpoint: URL
    /// Minimum log level to process.
    ///
    /// Default: LogLevel.Info
    let logLevel: LogLevel
    /// Whether or not to enable the automatic crash detection and logging.
    ///
    ///Default: true
    let enableCrashReporting: Bool
    /// Logs are cached locally on device, and sent once every pushInterval.
    /// Whether or not to enable automatic ui logging. Logs button presses and view controller appearances
    ///
    /// Default: true
    let enableUiLogging: Bool
    /// How often to push logs to remote.
    ///
    /// Default: 30 seconds
    let pushInterval: TimeInterval
    /// Enable Peavy to also print the log line to stdout
    /// (using builtin NSLog)
    ///
    /// If Peavy is being used directly from within code
    /// (ie. not through f.ex. Lumberjack), then you probably want
    /// this enabled in debug builds.
    let printToStdout: Bool
    /// Whether to enable library debug mode.
    /// This enables logging (to stdout only) of local Peavy actions
    ///
    /// Default: false
    let debug: Bool
    
    public init(
        endpoint: URL,
        logLevel: LogLevel = .info,
        enableCrashReporting: Bool = true,
        enableUiLogging: Bool = true,
        pushInterval: TimeInterval = 30,
        printToStdout: Bool = false,
        debug: Bool = false
    ) {
        self.endpoint = endpoint
        self.logLevel = logLevel
        self.enableCrashReporting = enableCrashReporting
        self.enableUiLogging = enableUiLogging
        self.pushInterval = pushInterval
        self.printToStdout = printToStdout
        self.debug = debug
    }
}
