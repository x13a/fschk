import Foundation

// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
// https://theevilbit.github.io/posts/dyld_insert_libraries_dylib_injection_in_macos_osx_deep_dive/

private let launchDirs: [String] = [
    "LaunchDaemons/",
    "LaunchAgents/",
]
private let userLaunchAgentsDir = "Library/LaunchAgents/"

private func parsePlist(_ fileURL: URL) throws -> PluginLaunch.Item {
    let data = try PropertyListSerialization.propertyList(
        from: try Data(contentsOf: fileURL),
        format: nil
    ) as! [String:Any]
    return PluginLaunch.Item(
        url: fileURL,
        program: data["Program"] as? String,
        programArguments: data["ProgramArguments"] as? [String],
        dyldLibraries: (data["EnvironmentVariables"] as? [String:Any])?
            .filter { $0.key.hasSuffix(EnvDyldInsertLibrariesSuffix) }
            .map { $0.value as! String }
    )
}

private func scan() throws -> [PluginLaunch.Item] {
    var dirs = FileManager
        .default
        .urls(for: .libraryDirectory, in: .localDomainMask)
        .flatMap { dir in launchDirs.map { dir.appendingPathComponent($0, isDirectory: true) } }
    dirs.append(contentsOf: try getUsersHomeDirs()
        .map { $0.appendingPathComponent(userLaunchAgentsDir, isDirectory: true) })
    return try dirs
        .lazy
        .compactMap { 
            try? FileManager.default.contentsOfDirectory(at: $0, includingPropertiesForKeys: nil)
        }
        .flatMap { try $0.map { try parsePlist($0) } }
}

struct PluginLaunch: Plugin { 
    struct Item: Codable {
        let url: URL
        let program: String?
        let programArguments: [String]?
        let dyldLibraries: [String]?
    }
    
    static func run() throws -> [Codable] { try scan() }

    static func pprint() throws {
        let items = try scan()
        printPluginHeader(#file, items.count)
        for item in items {
            print("\(item.url.path)")
            print("  prog -> \(item.program ?? "nil")")
            print("  args -> \(item.programArguments?.description ?? "nil")")
            print("  dyld -> \(item.dyldLibraries?.description ?? "nil")")
            print("")
        }
    }
}
