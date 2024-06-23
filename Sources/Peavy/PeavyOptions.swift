import Foundation

public struct PeavyOptions {
    let endpoint: URL
    let logLevel: LogLevel
    let enableCrashReporting: Bool
    let pushInterval: TimeInterval
    let printToStdout: Bool
    let debug: Bool
    
    public init(
        /**
         * The remote endpoint to push logs to.
         * Should be a full URL.
         */
        endpoint: URL,
        /**
         * Minimum log level to process.
         *
         * Default: LogLevel.Info
         */
        logLevel: LogLevel,
        /**
         * Whether or not to enable the automatic crash detection and logging.
         *
         * Default: true
         */
        enableCrashReporting: Bool = true,
        /**
         * How often to push logs to remote.
         * Logs are cached locally on device, and sent once every pushInterval.
         *
         * Default: 30 seconds
         */
        pushInterval: TimeInterval = 30,
        /**
         * Enable Peavy to also print the log line to stdout
         * (using builtin NSLog)
         *
         * If Peavy is being used directly from within code
         * (ie. not through f.ex. Lumberjack), then you probably want
         * this enabled in debug builds.
         */
        printToStdout: Bool = false,
        /**
         * Whether to enable library debug mode.
         * This enables logging (to stdout only) of local Peavy actions
         *
         * Default: false
         */
        debug: Bool = false
    ) {
        self.endpoint = endpoint
        self.logLevel = logLevel
        self.enableCrashReporting = enableCrashReporting
        self.pushInterval = pushInterval
        self.printToStdout = printToStdout
        self.debug = debug
    }
}
