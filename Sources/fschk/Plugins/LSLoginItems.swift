import Foundation

// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLoginItems.html

private let kGlobalLoginItems = "com.apple.LSSharedFileList.GlobalLoginItems" as CFString
private let types = [
    kLSSharedFileListSessionLoginItems,
    Unmanaged.passUnretained(kGlobalLoginItems),
]

private func getItems(for type: Unmanaged<CFString>) -> [PluginLSLoginItems.Item] {
    guard let sfl = LSSharedFileListCreate(nil, type.takeRetainedValue(), nil)?
        .takeRetainedValue() else {

        return []
    }
    guard let snapshot = LSSharedFileListCopySnapshot(sfl, nil)?
        .takeRetainedValue() as? [LSSharedFileListItem] else {

        return []
    }
    return snapshot
        .lazy
        .compactMap { LSSharedFileListItemCopyResolvedURL($0, 0, nil)?.takeRetainedValue() as URL? }
        .map { PluginLSLoginItems.Item(url: $0) }
}

private func scan() throws -> [PluginLSLoginItems.Item] { types.flatMap { getItems(for: $0) } }

struct PluginLSLoginItems: Plugin {
    struct Item: Codable {
        let url: URL
    }

    static func run() throws -> [Codable] { try scan() }

    static func pprint() throws {
        let items = try scan()
        printPluginHeader(#file, items.count)
        for item in items {
            print("path: \(item.url.path)")
        }
        print("")
    }
}
