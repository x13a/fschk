import Foundation

private let usersDir = "/Users/"

func getUsersHomeDirs() throws -> [URL] {
    try FileManager
        .default
        .contentsOfDirectory(atPath: usersDir)
        .compactMap { FileManager.default.homeDirectory(forUser: $0) }
}

func isRoot() -> Bool { getuid() == 0 }
