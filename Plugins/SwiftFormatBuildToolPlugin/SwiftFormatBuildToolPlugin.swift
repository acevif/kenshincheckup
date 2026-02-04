import Foundation
import PackagePlugin

@main
struct SwiftFormatBuildToolPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let sourceTarget = target as? SourceModuleTarget else {
            return []
        }

        let swiftFiles: [URL] = sourceTarget
            .sourceFiles(withSuffix: "swift")
            .map(\.url)

        guard !swiftFiles.isEmpty else {
            return []
        }

        let tool: PluginContext.Tool = try context.tool(named: "swiftformat")
        let outputDirectoryURL: URL = context.pluginWorkDirectoryURL.appendingPathComponent(target.name)
        try FileManager.default.createDirectory(
            at: outputDirectoryURL,
            withIntermediateDirectories: true,
        )
        let cacheURL: URL = outputDirectoryURL.appendingPathComponent("swiftformat.cache")
        let reportURL: URL = outputDirectoryURL.appendingPathComponent("swiftformat-report.json")
        var arguments: [String] = [
            "--lint",
            "--cache",
            cacheURL.path,
            "--reporter",
            "json",
            "--report",
            reportURL.path,
        ]

        arguments.append(contentsOf: swiftFiles.map(\.path))

        var inputFiles: [URL] = swiftFiles
        let configURL: URL = context.package.directoryURL.appendingPathComponent(".swiftformat")
        if FileManager.default.fileExists(atPath: configURL.path) {
            inputFiles.append(configURL)
        }

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
