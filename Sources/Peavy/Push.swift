import Foundation
import UIKit

internal struct PushError: Error {
    var localizedDescription = "Error pushing file"
}

internal class Push {
    private let storage: Storage
    
    init(_ storage: Storage) {
        self.storage = storage
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

        
        pusher()
    }
    
    func direct(_ message: Data) async throws {
        Debug.log("Pushing direct")
        var req = URLRequest(url: try Peavy.options.endpoint,
                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: 30)
        req.httpMethod = "POST"
        req.setValue("true", forHTTPHeaderField: "Peavy-Log")
        req.setValue("application/ndjson", forHTTPHeaderField: "Content-Type")
        let (data, resp) = try await URLSession.shared.upload(for: req, from: message)
        
        guard let response = resp as? HTTPURLResponse else {
            throw PushError()
        }
        guard response.statusCode < 400 else {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            throw PushError(localizedDescription: "Push error response: \(response.statusCode)\n\(body)")
        }
        Debug.log("Pushed direct")
    }
    
    private func pusher() {
        Task(priority: .background) {
            repeat {
                do {
                    try await Task.sleep(nanoseconds: UInt64(Peavy.options.pushInterval.rounded()) * 1_000_000_000)
                    try await push()
                } catch {
                    Debug.warn("Pusher failed to push: \(error.localizedDescription)")
                    try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                }
            } while !Task.isCancelled
        }
    }
    
    @objc private func didEnterBackground() {
        Debug.log("didEnterBackground, will push")
        Task(priority: .utility) {
            do {
                try await push()
            } catch {
                Debug.warn("Background failed to push: \(error.localizedDescription)")
            }
        }
    }
    
    private func push() async throws {
        await storage.rollCurrent()
        var errorCount = 0
        await storage.eachRolled { fileUrl in
            do {
                try await self.pushFile(fileUrl)
                try FileManager.default.removeItem(at: fileUrl)
                errorCount = 0
            } catch {
                Debug.warn("Failed to push file: \(error.localizedDescription)")
                errorCount += 1
            }
            return errorCount < 3
        }
    }
    
    private func pushFile(_ url: URL) async throws {
        Debug.log("Pushing file \(url.lastPathComponent)")
        var req = URLRequest(url: try Peavy.options.endpoint,
                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: 30)
        req.httpMethod = "POST"
        req.setValue("true", forHTTPHeaderField: "Peavy-Log")
        req.setValue("application/ndjson", forHTTPHeaderField: "Content-Type")
        req.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
        let (data, resp) = try await URLSession.shared.upload(for: req, fromFile: url)
        
        guard let response = resp as? HTTPURLResponse else {
            throw PushError()
        }
        guard response.statusCode < 400 else {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            throw PushError(localizedDescription: "Push error response: \(response.statusCode)\n\(body)")
        }
        Debug.log("Pushed file \(url.lastPathComponent)")
    }
}
