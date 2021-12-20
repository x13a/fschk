import Foundation

private let usersDir = "/Users/"

func getUsersHomeDirs() throws -> [URL] {
    try FileManager
        .default
        .contentsOfDirectory(atPath: usersDir)
        .compactMap { FileManager.default.homeDirectory(forUser: $0) }
}

func isRoot() -> Bool { getuid() == 0 }

func printPluginHeader(_ file: String, _ count: Int) {
    let name = URL(fileURLWithPath: file).deletingPathExtension().lastPathComponent
    let header = "\(name) (\(count))"
    print(header)
    print(String(repeating: "-", count: header.count))
    print("")
}
