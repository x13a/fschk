import Foundation

private let map = [
    PluginHash.Kind.paths: [
        "/etc/paths.d/": [:],
    ],
    PluginHash.Kind.startupItems: [
        "/Library/StartupItems/": [:],
    ],
]

private func scan() throws -> [PluginHash.Item] {
    var results = [PluginHash.Item]()
    for (kind, paths) in map {
        for (path, value) in paths {
            let path = URL(fileURLWithPath: path)
            guard try path.checkResourceIsReachable() else { continue }
            var itemFiles = [URL]()
            if path.hasDirectoryPath {
                guard let files = try? FileManager
                    .default
                    .contentsOfDirectory(at: path, includingPropertiesForKeys: nil) else { continue }
                
                for file in files {
                    if value[file.lastPathComponent] == nil {
                        itemFiles.append(file)
                    }
                }
                if !itemFiles.isEmpty {
                    results.append(PluginHash.Item(url: path, kind: kind, files: itemFiles))
                }
            }
        }
    }
    return results
}

struct PluginHash: Plugin {
    enum Kind: Codable {
        // https://0xmachos.com/2021-05-13-zsh-path-macos/
        case paths
        // https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/StartupItems.html
        case startupItems
    }
    struct Item: Codable {
        let url: URL
        let kind: Kind
        let files: [URL]
    }

    static func run() throws -> [Codable] { try scan() }

    static func pprint() throws {
        let items = try scan()
        printPluginHeader(#file, items.map { $0.files.count }.reduce(0, +))
        for item in items {
            if item.url.hasDirectoryPath {
                print("\(item.url.path)")
                switch item.kind {
                case .paths:
                    for file in item.files {
                        let values = try String(contentsOf: file)
                            .split(separator: "\n")
                            .map { String($0) }
                        print("  \(file.lastPathComponent) -> \(values)")
                    }
                default:
                    for file in item.files {
                        print("  \(file.lastPathComponent)")
                    }
                }
                print("")
            }
        }
    }
}
