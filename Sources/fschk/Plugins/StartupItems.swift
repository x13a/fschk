import Foundation

// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/StartupItems.html

private let startupItemsDir = "StartupItems/"

private func scan() throws -> [PluginStartupItems.Item] {
    FileManager
        .default
        .urls(for: .libraryDirectory, in: .localDomainMask)
        .lazy
        .compactMap { 
            try? FileManager.default.contentsOfDirectory(
                at: $0.appendingPathComponent(startupItemsDir, isDirectory: true), 
                includingPropertiesForKeys:nil
            ) 
        }
        .flatMap { $0 }
        .map { PluginStartupItems.Item(url: $0) }
}

struct PluginStartupItems: Plugin {
    struct Item: Codable {
        let url: URL
    }

    static func run() throws -> [Codable] { try scan() }

    static func pprint() throws {
        let items = try scan()
        printPluginHeader(#file, items.count)
        for item in items {
            print("path: \(item.url.path)")
        }
        if !items.isEmpty {
            print("")
        }
    }
}
