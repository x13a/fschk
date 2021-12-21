import Foundation
import CodeSign

// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLoginItems.html
// https://theevilbit.github.io/posts/dyld_insert_libraries_dylib_injection_in_macos_osx_deep_dive/

private let itemsPaths = [
    "Contents/Library/LoginItems/",
    "Contents/Library/XPCServices/",
]
private let systemExtensionsPath = "Contents/Library/SystemExtensions/"

private func scanApplication(_ bundle: Bundle) -> PluginApplication.Item? {
    var hasItemsDir = false
    var items = [URL]()
    for itemsPath in itemsPaths {
        if let apps = try? FileManager.default.contentsOfDirectory(
            at: bundle.bundleURL.appendingPathComponent(itemsPath), 
            includingPropertiesForKeys: nil
        ) {
            hasItemsDir = true
            for app in apps {
                guard let appBundle = Bundle(url: app) else { continue }
                items.append(appBundle.bundleURL)
            }
        }
    }
    let systemExtensions = (try? FileManager.default.contentsOfDirectory(
        at: bundle.bundleURL.appendingPathComponent(systemExtensionsPath), 
        includingPropertiesForKeys: nil
    ))?.filter { $0.pathExtension == "systemextension" }
    var extensions = [URL]()
    if let plugInsURL = bundle.builtInPlugInsURL {
        if let plugIns = try? FileManager.default.contentsOfDirectory(
            at: plugInsURL, 
            includingPropertiesForKeys: nil
        ) {
            extensions = plugIns.filter { $0.pathExtension == "appex" }
        }
    }
    let dyldLibraries = (bundle.infoDictionary?["LSEnvironment"] as? [String:Any])?
        .filter { $0.key.hasSuffix(EnvDyldInsertLibrariesSuffix) }
        .map { $0.value as! String }
    if hasItemsDir
        || systemExtensions != nil 
        || !extensions.isEmpty
        || !(dyldLibraries?.isEmpty ?? true) {
        
        return PluginApplication.Item(
            url: bundle.bundleURL, 
            items: hasItemsDir ? items : nil, 
            systemExtensions: systemExtensions, 
            extensions: extensions.isEmpty ? nil : extensions,
            dyldLibraries: dyldLibraries
        )
    }
    return nil
}

private func scanDir(_ dir: URL) throws -> [PluginApplication.Item] {
    guard let files = try? FileManager.default.contentsOfDirectory(
        at: dir, 
        includingPropertiesForKeys: nil
    ) else { return [] }
    let requirement = try CodeSign.createRequirement(with: CodeSignRequirementString.apple).get()
    var results = [PluginApplication.Item]()
    for file in files {
        guard file.hasDirectoryPath else { continue }
        guard file.pathExtension != "" else {
            results.append(contentsOf: try scanDir(file))
            continue
        }
        if let code = try? CodeSign.createCode(with: file).get() {
            if case .success = CodeSign.checkValidity(for: code, requirement: requirement) {
                continue
            }
        }
        guard let bundle = Bundle(url: file) else { continue }
        guard let item = scanApplication(bundle) else { continue }
        results.append(item)
    }
    return results
}

private func scan() throws -> [PluginApplication.Item] {
    var dirs = FileManager.default.urls(for: .applicationDirectory, in: .localDomainMask)
    dirs.append(contentsOf: try getUsersHomeDirs()
        .map { $0.appendingPathComponent("Applications", isDirectory: true) })
    return try dirs.flatMap { try scanDir($0) }
}

struct PluginApplication: Plugin {
    struct Item: Codable {
        let url: URL
        let items: [URL]?
        let systemExtensions: [URL]?
        let extensions: [URL]?
        let dyldLibraries: [String]?
    }

    static func run() throws -> [Codable] { try scan() }

    static func pprint() throws {
        let items = try scan()
        printPluginHeader(#file, items.count)
        for item in items {
            let pathLen = item.url.path.count
            print("\(item.url.path)")
            let itemItems = item.items?.map { $0.path.dropFirst(pathLen) }.description ?? "nil"
            print("  items -> \(itemItems)")
            let exts = item.extensions?.map { $0.path.dropFirst(pathLen) }.description ?? "nil"
            print("  exts -> \(exts)")
            let sexts = item
                .systemExtensions?
                .map { $0.path.dropFirst(pathLen) }
                .description ?? "nil"
            print("  sexts -> \(sexts)")
            print("  dyld -> \(item.dyldLibraries?.description ?? "nil")")
            print("")
        }
    }
}
