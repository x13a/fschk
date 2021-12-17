import Foundation

// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/StartupItems.html

private let startupDir = "/Library/StartupItems/"

private func process() throws -> [PluginStartupItems.Item] {
    try FileManager
        .default
        .contentsOfDirectory(
            at: URL(fileURLWithPath: startupDir, isDirectory: true), 
            includingPropertiesForKeys: nil
        ).map { PluginStartupItems.Item(url: $0) }
}

struct PluginStartupItems {
    struct Item {
        let url: URL
    }

    static func run() throws -> [Item] { try process() }

    static func pprint() throws {
        print("StartupItems")
        print("------------\n")
        for item in try process() {
            print("path: \(item.url.path)")
        }
        print("")
    }
}
