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
        let configURL: URL = context.package.directoryURL.appendingPathComponent(".swiftformat")
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            return []
        }
        var arguments: [String] = [
            "--lint",
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
                outputFiles: [],
            ),
        ]
    }
}
