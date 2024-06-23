import Foundation
import CrashReporter


public class Peavy {
    private init(_ options: PeavyOptions) throws {
        Debug.enabled = options.debug

        self.options = options
        self.storage = try Storage()
        self.logger = Logger(storage)
        self.push = Push(storage)

        setupCrashReporting()
        
        Debug.log("Peavy initialised")
    }
    
    private static var _instance: Peavy?
    internal static var instance: Peavy {
        if _instance == nil {
            fatalError("Peavy has not been setup. Make sure you call Peavy.setup() first")
        }
        return _instance!
    }
    
    internal let options: PeavyOptions
    internal static var options: PeavyOptions {
        instance.options
    }

    internal let logger: Logger
    internal let push: Push
    private let storage: Storage
    internal var crashReporter: PLCrashReporter?

    public static func setup(_ options: PeavyOptions) {
        _instance = try? Peavy(options)
    }
}
