import Foundation

public enum EventState {
    case platformVersion
    case appVersion
    case appVersionCode
    case deviceModel
    case deviceLanguage
    case deviceScreenWidth
    case deviceScreenHeight
    case uiTheme
    case networkType
    case notifications
    case availableMemory
    
    public var stringValue: String {
        switch self {
        case .platformVersion: "platform-version"
        case .appVersion: "app-version"
        case .appVersionCode: "app-version-code"
        case .deviceModel: "device-model"
        case .deviceLanguage: "device-language"
        case .deviceScreenWidth: "device-screen-w"
        case .deviceScreenHeight: "device-screen-h"
        case .uiTheme: "ui-theme"
        case .networkType: "network-type"
        case .notifications: "notifications"
        case .availableMemory: "available-memory"
        }
    }
}
