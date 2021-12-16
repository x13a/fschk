import Foundation

private let launchDirs: [String] = [
    "/Library/LaunchDaemons/",
    "/Library/LaunchAgents/",
]
private let userLaunchDir = "Library/LaunchAgents/"
private let usersDir = "/Users/"

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

private func getUsersHomeDirs() throws -> [URL] {
    try FileManager
        .default
        .contentsOfDirectory(atPath: usersDir)
        .lazy
        .map { FileManager.default.homeDirectory(forUser: $0) }
        .filter { $0 != nil }
        .map { $0! }
}

private func process() throws -> [PluginLaunch.Item] {
    var dirs = [URL]()
    dirs.append(contentsOf: launchDirs.map { URL(fileURLWithPath: $0, isDirectory: true) })
    dirs.append(contentsOf: try getUsersHomeDirs()
        .map { $0.appendingPathComponent(userLaunchDir, isDirectory: true) })
    var results = [PluginLaunch.Item]()
    for dir in dirs {
        for fileUrl in try FileManager
            .default
            .contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {

            results.append(try parsePlist(fileUrl))
        }
    }
    return results
}

struct PluginLaunch { 
    struct Item {
        let url: URL
        let program: String?
        let programArguments: [String]?
    }
    
    static func run() throws -> [Item] { try process() }

    static func pprint() throws {
        let items = try process()
        print("Launch items")
        print("------------\n")
        for (index, item) in items.enumerated() {
            print("path: \(item.url.path)")
            print("prog: \(item.program ?? "")")
            print("args: \(item.programArguments ?? [])")
            if index != items.count - 1 {
                print("")
            }
        }
    }
}
