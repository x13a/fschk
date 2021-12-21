import Foundation

func getUsersHomeDirs() throws -> [URL] {
    try FileManager
        .default
        .urls(for: .userDirectory, in: .localDomainMask)
        .flatMap { try FileManager.default.contentsOfDirectory(atPath: $0.path) }
        .compactMap { FileManager.default.homeDirectory(forUser: $0) }
}

func isRoot() -> Bool { getuid() == 0 }

func printPluginHeader(_ path: String, _ count: Int) {
    let name = URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
    let header = "\(name) (\(count))"
    print(header)
    print(String(repeating: "-", count: header.count))
    print("")
}
