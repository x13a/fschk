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

struct PluginLaunch { 
    struct Item {
        let url: URL
        let program: String?
        let programArguments: [String]?
    }
    
    static func run() throws -> [Item] { try scan() }

    static func pprint() throws {
        print("Launch")
        print("------\n")
        for item in try scan() {
            print("path: \(item.url.path)")
            if let program = item.program {
                print("prog: \(program)")
            }
            if let programArguments = item.programArguments {
                print("args: \(programArguments)")
            }
            print("")
        }
        print("")
    }
}
