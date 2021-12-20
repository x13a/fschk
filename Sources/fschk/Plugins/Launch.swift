import Foundation

// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html

private let launchDirs: [String] = [
    "/Library/LaunchDaemons/",
    "/Library/LaunchAgents/",
]
private let userLaunchDir = "Library/LaunchAgents/"

private func parsePlist(_ fileUrl: URL) throws -> PluginLaunch.Item {
    let data = try PropertyListSerialization.propertyList(
        from: try Data(contentsOf: fileUrl),
        format: nil
    ) as! [String:Any]
    return PluginLaunch.Item(
        url: fileUrl,
        program: data["Program"] as? String,
        programArguments: data["ProgramArguments"] as? [String]
    )
}

private func scan() throws -> [PluginLaunch.Item] {
    var dirs = launchDirs.map { URL(fileURLWithPath: $0, isDirectory: true) }
    dirs.append(contentsOf: try getUsersHomeDirs()
        .map { $0.appendingPathComponent(userLaunchDir, isDirectory: true) })
    return try dirs
        .lazy
        .compactMap { 
            try? FileManager
                .default
                .contentsOfDirectory(at: $0, includingPropertiesForKeys: nil)
        }
        .flatMap { try $0.map { try parsePlist($0) } }
}

struct PluginLaunch: Plugin { 
    struct Item: Codable {
        let url: URL
        let program: String?
        let programArguments: [String]?
    }
    
    static func run() throws -> [Codable] { try scan() }

    static func pprint() throws {
        let items = try scan()
        printPluginHeader(#file, items.count)
        for item in items {
            print("path: \(item.url.path)")
            print("prog: \(item.program ?? "nil")")
            print("args: \(item.programArguments ?? [])")
            print("")
        }
        print("")
    }
}
