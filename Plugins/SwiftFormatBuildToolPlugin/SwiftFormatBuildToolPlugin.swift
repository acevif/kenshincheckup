import Foundation
import PackagePlugin

@main
struct SwiftFormatBuildToolPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else {
            throw SwiftFormatBuildToolPluginError.unsupportedTarget(target.name)
        }

        let swiftFiles: [URL] = sourceTarget
            .sourceFiles(withSuffix: "swift")
            .map(\.url)

        guard !swiftFiles.isEmpty else {
            throw SwiftFormatBuildToolPluginError.noSwiftFiles(target.name)
        }

        let tool: PluginContext.Tool = try context.tool(named: "swiftformat")
        let outputDirectoryURL: URL = context.pluginWorkDirectoryURL.appendingPathComponent(target.name)
        try FileManager.default.createDirectory(
            at: outputDirectoryURL,
            withIntermediateDirectories: true,
        )
        let configURL: URL = context.package.directoryURL.appendingPathComponent(".swiftformat")
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            throw SwiftFormatBuildToolPluginError.missingConfig(configURL)
        }
        let reportURL: URL = outputDirectoryURL.appendingPathComponent("swiftformat-report.json")
        var arguments: [String] = [
            "--lint",
            "--reporter",
            "json",
            "--report",
            reportURL.path,
        ]

        arguments.append(contentsOf: swiftFiles.map(\.path))

        let inputFiles: [URL] = swiftFiles + [configURL]

        return [
            .buildCommand(
                displayName: "SwiftFormat lint (\(target.name))",
                executable: tool.url,
                arguments: arguments,
                environment: [:],
                inputFiles: inputFiles,
                outputFiles: [reportURL],
            ),
        ]
    }
}

private enum SwiftFormatBuildToolPluginError: Error, LocalizedError {
    case missingConfig(URL)
    case noSwiftFiles(String)
    case unsupportedTarget(String)

    var errorDescription: String? {
        switch self {
        case let .missingConfig(url):
            "SwiftFormat config missing at \(url.path)"
        case let .noSwiftFiles(targetName):
            "SwiftFormat target '\(targetName)' has no Swift source files"
        case let .unsupportedTarget(targetName):
            "SwiftFormat target '\(targetName)' is not a source module"
        }
    }
}
