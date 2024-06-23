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
    
    private func flusher() {
        Task(priority: .background) {
            while (true) {
                do {
                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                    try await flush()
                } catch {
                    Debug.warn("\(error.localizedDescription)")
                }
            }
        }
    }
    
    private func compacter() {
        Task(priority: .background) {
            while (true) {
                do {
                    try await Task.sleep(nanoseconds: 30 * 1_000_000_000)
                    try await compact()
                } catch {
                    Debug.warn("\(error.localizedDescription)")
                }
            }
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
