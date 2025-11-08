//
//  Peavy+SessionId.swift
//  Peavy
//
//  Created by Magnus on 08/11/2025.
//

import Foundation
import UIKit

fileprivate var pausedAt: Date?

internal extension Peavy {
    @objc private func didEnterBackground() {
        pausedAt = Date()
    }

    @objc private func willEnterForeground() {
        if !Peavy.isSetup { return }
        
        let resumeAt = Date()
        if let pausedAt = pausedAt, resumeAt.timeIntervalSince(pausedAt) > 15 * 60 {
            self.logger.resetSessionId()
        }
        pausedAt = nil
    }
    
    func setupSessionId() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
}
