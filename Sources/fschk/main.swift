import ArgumentParser

private let Version = "0.1.5"

protocol Plugin {
    static func run() throws -> [Codable]
    static func pprint() throws
}

private let plugins: [Plugin.Type] = [
    PluginLaunch.self,
    PluginLSLoginItem.self,
    PluginHash.self,
    PluginApplication.self,
]

private func check() throws {
    for plugin in plugins {
        try plugin.pprint()
    }
}

private struct Fschk: ParsableCommand {
    @Flag(help: "Print version and exit")
    var version = false

    mutating func run() throws {
        if version {
            print(Version)
            return
        }
        try check()
    }
}

Fschk.main()
