import Foundation

extension Peavy {
    static func setMeta(_ map: Labels) {
        instance.logger.meta.merge(map, uniquingKeysWith: { $1 })
    }
    
    static func clearMeta() {
        instance.logger.meta.removeAll()
    }

    static func t(_ message: @autoclosure () -> String, _ error: Error? = nil) {
        if instance.options.logLevel >= .trace {
            instance.logger.log(LogEntry(
                timestamp: Date(),
                level: .trace,
                message: message(),
                error: error
            ))
        }
    }
    
    static func d(_ message: @autoclosure () -> String, _ error: Error? = nil) {
        if instance.options.logLevel >= .debug {
            instance.logger.log(LogEntry(
                timestamp: Date(),
                level: .debug,
                message: message(),
                error: error
            ))
        }
    }
    
    static func i(_ message: @autoclosure () -> String, _ error: Error? = nil) {
        if instance.options.logLevel >= .info {
            instance.logger.log(LogEntry(
                timestamp: Date(),
                level: .info,
                message: message(),
                error: error
            ))
        }
    }
    
    static func w(_ message: @autoclosure () -> String, _ error: Error? = nil) {
        if instance.options.logLevel >= .warning {
            instance.logger.log(LogEntry(
                timestamp: Date(),
                level: .warning,
                message: message(),
                error: error
            ))
        }
    }
    
    static func e(_ message: @autoclosure () -> String, _ error: Error? = nil) {
        if instance.options.logLevel >= .error {
            instance.logger.log(LogEntry(
                timestamp: Date(),
                level: .error,
                message: message(),
                error: error
            ))
        }
    }
}
