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
    var results = [PluginLSLoginItems.Item]()
    for item in snapshot {
        guard let url = LSSharedFileListItemCopyResolvedURL(item, 0, nil)?
            .takeRetainedValue() as URL? else { continue }
        results.append(PluginLSLoginItems.Item(url: url))
    }
    return results
}

private func process() throws -> [PluginLSLoginItems.Item] { types.flatMap { getItems(for: $0) } }

struct PluginLSLoginItems {
    struct Item {
        let url: URL
    }

    static func run() throws -> [Item] { try process() }

    static func pprint() throws {
        print("LSLoginItems")
        print("------------\n")
        for item in try process() {
            print("path: \(item.url.path)")
        }
        print("")
    }
}
