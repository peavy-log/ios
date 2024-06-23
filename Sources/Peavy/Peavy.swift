import Foundation

public class Peavy {
    private init(_ options: PeavyOptions) throws {
        self.options = options
        self.storage = try Storage()
        self.logger = Logger(storage)
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
    private let storage: Storage

    public static func setup(_ options: PeavyOptions) {
        _instance = try? Peavy(options)
    }
}
