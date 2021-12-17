import Foundation

private let usersDir = "/Users/"

func getUsersHomeDirs() throws -> [URL] {
    try FileManager
        .default
        .contentsOfDirectory(atPath: usersDir)
        .lazy
        .map { FileManager.default.homeDirectory(forUser: $0) }
        .filter { $0 != nil }
        .map { $0! }
}

func isRoot() -> Bool { getuid() == 0 }
