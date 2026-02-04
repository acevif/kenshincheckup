import ArgumentParser
import Foundation
import KenshinCheckupCore
import Logging

fileprivate let logger = Logger(label: "kenshin.checkup")

public struct CheckupSubcommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "checkup",
        abstract: "Run checkups using the config file."
    )

    @Option(name: [.short, .long], help: "Path to config file.")
    public var config: String?

    public init() {}

    public func run() throws {
        let homePath = ProcessInfo.processInfo.environment["HOME"]
            ?? FileManager.default.homeDirectoryForCurrentUser.path
        let configPath = config.map { Self.resolvePath($0, homePath: homePath) }
            ?? Self.defaultConfigPath(homePath: homePath)
        let configURL = URL(fileURLWithPath: configPath)

        let commandRunner = SystemCommandRunner()

        do {
            let loaded = try ConfigLoader.load(from: configURL)
            let plugin = ChezmoiUnmanagedPlugin(
                patterns: loaded.chezmoiUnmanaged.patterns,
                commandRunner: commandRunner,
                fileManager: .default
            )
            let result = plugin.run()
            OutputFormatter.write(result)
            if result.hasIssue {
                throw ArgumentParser.ExitCode.failure
            }
        } catch {
            logger.error(
                "config load failed",
                metadata: [
                    "path": "\(configURL.path)",
                    "error": "\(error)",
                    "errorType": "\(type(of: error))",
                ]
            )
            let result = CheckResult(
                id: "doctor_chezmoi_unmanaged",
                description: "Detect unmanaged config files.",
                entries: [
                    CheckEntry(
                        result: .failed,
                        message: "config load failed",
                        details: ["path: \(configURL.path)", "error: \(error)"]
                    ),
                ]
            )
            OutputFormatter.write(result)
            throw ArgumentParser.ExitCode.failure
        }
    }

    public static func defaultConfigPath(homePath: String) -> String {
        URL(fileURLWithPath: homePath)
            .appendingPathComponent(".config")
            .appendingPathComponent("kenshin")
            .appendingPathComponent("config.toml")
            .path
    }

    public static func resolvePath(_ path: String, homePath: String) -> String {
        if path == "~" {
            return homePath
        }
        if path.hasPrefix("~/") {
            let suffix = String(path.dropFirst(2))
            return URL(fileURLWithPath: homePath).appendingPathComponent(suffix).path
        }
        return path
    }
}
