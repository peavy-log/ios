import Foundation
import CrashReporter

private struct CrashLogError: Error {
    var localizedDescription: String
    
    init(localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }
}

internal extension Peavy {
    func setupCrashReporting() {
        if options.enableCrashReporting && !isDebuggerAttached() {
            let config = PLCrashReporterConfig(signalHandlerType: .mach, symbolicationStrategy: [])
            
            guard let crashReporter = PLCrashReporter(configuration: config) else {
                Debug.warn("Failed to instantiate PLCrashReporter")
                return
            }
            self.crashReporter = crashReporter

            do {
                try crashReporter.enableAndReturnError()
            } catch {
                Debug.warn("Failed to enable crash reporter: \(error)")
            }
            
            flushCrashLog()
        } else {
            
        }
    }
    
    private func flushCrashLog() {
        Task(priority: .background) {
            guard let reporter = crashReporter else { return }

            if reporter.hasPendingCrashReport() {
                do {
                    let data = try reporter.loadPendingCrashReportDataAndReturnError()
                    let report = try PLCrashReport(data: data)

                    if let text = PLCrashReportTextFormatter.stringValue(for: report, with: PLCrashReportTextFormat(1)) {
                        let timestamp = report.systemInfo.timestamp ?? Date()
                        let error = CrashLogError(localizedDescription: text)
                        
                        logger.log(LogEntry(timestamp: timestamp,
                                            level: .error,
                                            message: "Uncaught exception",
                                            error: error))
                    } else {
                        Debug.warn("CrashReporter: can't convert report to text")
                    }
                } catch let error {
                    Debug.warn("CrashReporter: failed to load and parse: \(error)")
                }
            }
        }
    }
    
    private func isDebuggerAttached() -> Bool {
        #if !TARGET_OS_IPHONE
        return false
        #endif
        
        var info = kinfo_proc()
        var infoSize = MemoryLayout.size(ofValue: info)
        var name = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        
        let result = name.withUnsafeMutableBufferPointer { namePointer -> Int32 in
            return sysctl(namePointer.baseAddress, 4, &info, &infoSize, nil, 0)
        }
        
        if result == -1 {
            NSLog("sysctl() failed: %s", strerror(errno))
            return false
        }
        
        if (info.kp_proc.p_flag & P_TRACED) != 0 {
            return true
        }
        
        return false
    }
}
