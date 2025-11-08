import Foundation
import UIKit
import CoreTelephony
import SystemConfiguration
import UserNotifications

internal extension Peavy {
    static func sendState() {
        state(.uiTheme, value: getUITheme())
        state(.networkType, value: getNetworkType())
        state(.notifications, value: getNotificationStatus())
        state(.availableMemory, value: getAvailableMemory())
        state(.platformVersion, value: UIDevice.current.systemVersion)
        if let version = getAppVersion() {
            state(.appVersion, value: version.0)
            state(.appVersionCode, value: version.1)
        }
        state(.deviceModel, value: UIDevice.current.modelName)
        state(.deviceLanguage, value: Locale.current.identifier.replacingOccurrences(of: "_", with: "-"))
        state(.deviceScreenWidth, value: Int(UIScreen.main.bounds.width.rounded()))
        state(.deviceScreenHeight, value: Int(UIScreen.main.bounds.height.rounded()))
    }
    
    private static func getUITheme() -> String {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark ? "dark" : "light"
        }
        return "light"
    }
    
    private static func getNetworkType() -> String {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return "none"
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return "none"
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        if !isReachable || needsConnection {
            return "none"
        }
        
        if flags.contains(.isWWAN) {
            let networkInfo = CTTelephonyNetworkInfo()
            if let radioAccessTechnology = networkInfo.serviceCurrentRadioAccessTechnology?.values.first {
                return getRadioAccessTechnologyString(radioAccessTechnology)
            }
            return "cellular"
        }
        
        return "wifi"
    }
    
    private static func getRadioAccessTechnologyString(_ technology: String) -> String {
        switch technology {
        case CTRadioAccessTechnologyGPRS,
             CTRadioAccessTechnologyEdge,
             CTRadioAccessTechnologyCDMA1x:
            return "2g"
            
        case CTRadioAccessTechnologyWCDMA,
             CTRadioAccessTechnologyHSDPA,
             CTRadioAccessTechnologyHSUPA,
             CTRadioAccessTechnologyCDMAEVDORev0,
             CTRadioAccessTechnologyCDMAEVDORevA,
             CTRadioAccessTechnologyCDMAEVDORevB,
             CTRadioAccessTechnologyeHRPD:
            return "3g"
            
        case CTRadioAccessTechnologyLTE:
            return "4g"
            
        case CTRadioAccessTechnologyNRNSA,
             CTRadioAccessTechnologyNR:
            return "5g"
            
        default:
            return "unknown"
        }
    }
    
    private static func getNotificationStatus() -> String {
        var isEnabled = false
        let semaphore = DispatchSemaphore(value: 0)
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            isEnabled = settings.authorizationStatus == .authorized
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 1)
        return isEnabled ? "enabled" : "disabled"
    }
    
    private static func getAvailableMemory() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            return Int64(ProcessInfo.processInfo.physicalMemory)
        }
        return 0
    }
    
    private static func getAppVersion() -> (String, String)? {
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
              let code = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
            return nil
        }
        return (version, code)
    }
}
