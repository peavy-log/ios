import Foundation

internal struct PushError: Error {
    var localizedDescription = "Error pushing file"
}

internal class Push {
    private let storage: Storage
    
    init(_ storage: Storage) {
        self.storage = storage
        
        pusher()
    }
    
    private func pusher() {
        Task(priority: .background) {
            repeat {
                do {
                    try await Task.sleep(nanoseconds: UInt64(Peavy.options.pushInterval.rounded()) * 1_000_000_000)
                    try await push()
                } catch {
                    Debug.warn("\(error.localizedDescription)")
                }
            } while !Task.isCancelled
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
                Debug.warn("\(error.localizedDescription)")
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
