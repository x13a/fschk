import Foundation

private let launchPaths: [String] = [
    "/Library/LaunchDaemons/",
    "/Library/LaunchAgents/",
]
private let userLaunchPath = "Library/LaunchAgents/"
private let usersDir = "/Users/"

private func parsePlist(_ url: URL) throws -> PluginLaunch.Item {
    var format = PropertyListSerialization.PropertyListFormat.xml
    let data = try PropertyListSerialization.propertyList(
        from: try Data(contentsOf: url),
        options: .mutableContainersAndLeaves,
        format: &format
    ) as! [String:Any]
    return PluginLaunch.Item(
        url: url,
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
    var paths = [URL]()
    paths.append(contentsOf: launchPaths.map { URL(fileURLWithPath: $0, isDirectory: true) })
    paths.append(contentsOf: try getUsersHomeDirs()
        .map { $0.appendingPathComponent(userLaunchPath, isDirectory: true) })
    var results = [PluginLaunch.Item]()
    for path in paths {
        for file in try FileManager
            .default
            .contentsOfDirectory(at: path, includingPropertiesForKeys: nil) {

            results.append(try parsePlist(file))
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
    
    static func run() throws -> [PluginLaunch.Item] {
        try process()
    }

    static func pprint() throws {
        let items = try process()
        print("Checking launch items...")
        print("------------------------\n")
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
