import Foundation

extension Peavy {
    public static func ev(
        _ type: EventType,
        category: String,
        name: String,
        ident: String = "",
        duration: TimeInterval = 0,
        result: EventResult = .success
    ) {
        instance.logger.log(LogEntry(
            timestamp: Date(),
            level: .info,
            message: "",
            error: nil,
            labels: [:],
            json: [
                "__peavy_type": "event",
                "message": "", // empty out the default message
                "type": type.stringValue,
                "category": category,
                "name": name,
                "ident": ident,
                "duration": Int(duration * 1000), // should be milliseconds
                "result": result.stringValue,
            ]
        ))
    }
    
    public static func action(
        _ category: String,
        _ name: String,
        ident: String = "",
        duration: TimeInterval = 0,
        result: EventResult = .success
    ) {
        ev(
            .action,
            category: category,
            name: name,
            ident: ident,
            duration: duration,
            result: result
        )
    }
    
    public static func action(
        category: String,
        name: String,
        ident: Int,
        duration: TimeInterval = 0,
        result: EventResult = .success
    ) {
        ev(
            .action,
            category: category,
            name: name,
            ident: String(ident),
            duration: duration,
            result: result
        )
    }
    
    public static func action(
        category: String,
        name: String,
        ident: Int64,
        duration: TimeInterval = 0,
        result: EventResult = .success
    ) {
        ev(
            .action,
            category: category,
            name: name,
            ident: String(ident),
            duration: duration,
            result: result
        )
    }
    
    public static func action(
        category: String,
        name: String,
        ident: Double,
        duration: TimeInterval = 0,
        result: EventResult = .success
    ) {
        ev(
            .action,
            category: category,
            name: name,
            ident: String(ident),
            duration: duration,
            result: result
        )
    }
    
    public static func action(
        category: String,
        name: String,
        ident: Bool,
        duration: TimeInterval = 0,
        result: EventResult = .success
    ) {
        ev(
            .action,
            category: category,
            name: name,
            ident: String(ident),
            duration: duration,
            result: result
        )
    }
    
    internal static func state(_ name: EventState, value: String) {
        ev(.state, category: "device", name: name.stringValue, ident: value)
    }
    
    internal static func state(_ name: EventState, value: Int) {
        ev(
            .state,
            category: "device",
            name: name.stringValue,
            ident: String(value)
        )
    }
    
    internal static func state(_ name: EventState, value: Int64) {
        ev(
            .state,
            category: "device",
            name: name.stringValue,
            ident: String(value)
        )
    }
    
    internal static func state(_ name: EventState, value: Double) {
        ev(
            .state,
            category: "device",
            name: name.stringValue,
            ident: String(value)
        )
    }
    
    internal static func state(_ name: EventState, value: Bool) {
        ev(
            .state,
            category: "device",
            name: name.stringValue,
            ident: String(value)
        )
    }
}
