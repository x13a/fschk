import Foundation

// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/StartupItems.html

private let startupDir = "/Library/StartupItems/"

private func scan() throws -> [PluginStartupItems.Item] {
    try FileManager
        .default
        .contentsOfDirectory(
            at: URL(fileURLWithPath: startupDir, isDirectory: true), 
            includingPropertiesForKeys: nil
        )
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
        print("")
    }
}
