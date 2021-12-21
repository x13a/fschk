import Foundation

// https://0xmachos.com/2021-05-13-zsh-path-macos/

private let pathsDir = "/etc/paths.d/"

private func scan() throws -> [PluginPaths.Item] {
    try FileManager
        .default
        .contentsOfDirectory(
            at: URL(fileURLWithPath: pathsDir, isDirectory: true), 
            includingPropertiesForKeys: nil
        )
        .map { 
            PluginPaths.Item(
                url: $0, 
                vals: try String(contentsOf: $0).split(separator: "\n").map { String($0) }
            ) 
        }

}

struct PluginPaths: Plugin {
    struct Item: Codable {
        let url: URL
        let vals: [String]
    }

    static func run() throws -> [Codable] { try scan() }

    static func pprint() throws {
        let items = try scan()
        printPluginHeader(#file, items.count)
        for item in items {
            print("path: \(item.url.path)")
            print("vals: \(item.vals)")
            print("")
        }
    }
}
