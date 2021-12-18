import Foundation

// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html

private let launchDirs: [String] = [
    "/Library/LaunchDaemons/",
    "/Library/LaunchAgents/",
]
private let userLaunchDir = "Library/LaunchAgents/"

private func parsePlist(_ fileUrl: URL) throws -> PluginLaunch.Item {
    var format = PropertyListSerialization.PropertyListFormat.xml
    let data = try PropertyListSerialization.propertyList(
        from: try Data(contentsOf: fileUrl),
        options: .mutableContainersAndLeaves,
        format: &format
    ) as! [String:Any]
    return PluginLaunch.Item(
        url: fileUrl,
        program: data["Program"] as? String,
        programArguments: data["ProgramArguments"] as? [String]
    )
}

private func scan() throws -> [PluginLaunch.Item] {
    var dirs = [URL]()
    dirs.append(contentsOf: launchDirs.map { URL(fileURLWithPath: $0, isDirectory: true) })
    dirs.append(contentsOf: try getUsersHomeDirs()
        .map { $0.appendingPathComponent(userLaunchDir, isDirectory: true) })
    var results = [PluginLaunch.Item]()
    for dir in dirs {
        guard let files = try? FileManager
            .default
            .contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else { continue }
        results.append(contentsOf: try files.map { try parsePlist($0) })
    }
    return results
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
