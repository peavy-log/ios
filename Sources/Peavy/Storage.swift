import Foundation

internal actor Buffer {
    private var buffer: [LogEntry] = []
    
    func add(_ entry: LogEntry) {
        buffer.append(entry)
    }
    
    func drain() -> [LogEntry] {
        let entries = buffer
        buffer.removeAll(keepingCapacity: true)
        return entries
    }
}

internal class Storage {
    private static let MAX_FILE_SIZE = 1024 * 1024 // 1 MB
    private static let MAX_COMPACTED_SIZE = 1024 * 100 // 100 kB
    
    private let buffer = Buffer()
    private let file: StorageFile
    private let compactFile: CompactStorageFile
    
    init() throws {
        file = try StorageFile()
        compactFile = try CompactStorageFile()
        
        flusher()
        compacter()
    }
    
    func storeEntry(_ entry: LogEntry) async {
        await buffer.add(entry)
        Debug.log("Stored \(entry) to buffer")
    }
    
    func rollCurrent() async {
        Debug.log("Rolling current")
        try? await flush()
        await file.endCurrent(to: compactFile)
    }
    
    func eachRolled(_ each: @escaping (URL) async -> Bool) async {
        await compactFile.forInEnded(each)
    }
    
    private func flusher() {
        Task(priority: .background) {
            repeat {
                do {
                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                    try await flush()
                } catch {
                    Debug.warn("Failed to flush: \(error.localizedDescription)")
                }
            } while !Task.isCancelled
        }
    }
    
    private func compacter() {
        Task(priority: .background) {
            repeat {
                do {
                    try await Task.sleep(nanoseconds: 30 * 1_000_000_000)
                    try await compact()
                } catch {
                    Debug.warn("Failed to compact: \(error.localizedDescription)")
                }
            } while !Task.isCancelled
        }
    }
    
    private func flush() async throws {
        let entries = await buffer.drain()
        if entries.isEmpty {
            return
        }

        Debug.log("Flushing \(entries.count) entries")
        await file.write(entries: entries)
        Debug.log("Flushed \(entries.count) entries")
    }
    
    private func compact() async throws {
        if await file.currentSize() > Storage.MAX_FILE_SIZE {
            Debug.log("Current file is above max, rolling")
            await file.endCurrent(to: compactFile)
        }
        
        if await compactFile.all().count > 20 {
            Debug.log("More than 20 ended files, compacting")
            await compactFile.combineAll()
        }
    }
}
