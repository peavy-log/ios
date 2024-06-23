import Foundation
import DataCompression

internal struct GunzipError: Error {
    var localizedDescription = "Error gunzipping"
}
internal struct GZipError: Error {
    var localizedDescription = "Error gzipping"
}

internal actor CompactStorageFile {
    private let manager = FileManager.default
    private let folder: URL
    
    init() throws {
        do {
            let caches = try manager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            folder = caches.appendingPathComponent(".peavy")
            if !manager.fileExists(atPath: folder.path) {
                try manager.createDirectory(at: folder, withIntermediateDirectories: true)
            }
        } catch {
            NSLog("Error initialising Peavy storage: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func generateRollFile() -> URL {
        let milli = Int(Date().timeIntervalSince1970 * 1000)
        return folder.appendingPathComponent("c-" + String(milli))
    }
    
    func writeRolled(_ data: Data) throws {
        let rolled = generateRollFile()
        guard let compressed = data.gzip() else {
            throw GZipError()
        }
        Debug.log("Write compact, size: \(compressed.count)")
        manager.createFile(atPath: rolled.path, contents: compressed)
    }
    
    func all() -> [URL] {
        do {
            let files = try manager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
            return files.filter { $0.lastPathComponent.starts(with: "c-") }
        } catch {
            Debug.warn("\(error.localizedDescription)")
            return []
        }
    }
    
    func combineAll() {
        do {
            let files = all()
            
            var combinedData = Data()
            
            for file in files {
                let fileData = try Data(contentsOf: file)
                guard let decompressed = fileData.gunzip() else {
                    throw GunzipError()
                }
                combinedData.append(decompressed)
            }
            
            Debug.log("Combined data, orig size: \(combinedData.count)")
            try writeRolled(combinedData)
        } catch {
            Debug.warn("\(error.localizedDescription)")
        }
    }
    
    func forInEnded(_ each: @escaping (URL) async -> Void) async {
        await all().asyncEach(each)
    }
}

internal actor StorageFile {
    private let manager = FileManager.default
    private let folder: URL
    private var currentFile: URL
    
    init() throws {
        do {
            let caches = try manager.url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            folder = caches.appendingPathComponent(".peavy")
            if !manager.fileExists(atPath: folder.path) {
                try manager.createDirectory(at: folder, withIntermediateDirectories: true)
            }
            
            currentFile = folder.appendingPathComponent("current")
        } catch {
            NSLog("Error initialising Peavy storage: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func file(_ path: String) -> URL {
        return folder.appendingPathComponent(path)
    }
    
    func current() -> URL {
        if !manager.fileExists(atPath: currentFile.path) {
            manager.createFile(atPath: currentFile.path, contents: nil)
        }
        return currentFile
    }
    
    func currentSize() -> UInt64 {
        do {
            let attrs = try manager.attributesOfItem(atPath: current().path)
            return attrs[FileAttributeKey.size] as! UInt64
        } catch {
            Debug.warn("\(error.localizedDescription)")
            return 0
        }
    }
    
    func write(entries: [LogEntry]) {
        do {
            let handle = try FileHandle(forWritingTo: current())
            defer { try? handle.close() }
            try handle.seekToEnd()

            for entry in entries {
                var data = try entry.toJson()
                data.append("\n".data(using: .utf8)!)
                try handle.write(contentsOf: data)
            }
            
            try handle.synchronize()
        } catch {
            Debug.warn("\(error.localizedDescription)")
        }
    }
    
    func endCurrent(to: CompactStorageFile) async {
        do {
            let data = try Data(contentsOf: current())
            guard !data.isEmpty else { return }

            try await to.writeRolled(data)
            try manager.removeItem(at: current())
        } catch {
            Debug.warn("\(error.localizedDescription)")
        }
    }
}
