import Darwin

import ArgumentParser

private let Version = "0.1.0"

private func check() throws {
    try PluginLaunch.pprint()
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
