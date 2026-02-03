import ArgumentParser
import Foundation
import kenshincheckupCore

public struct KenshinCheckupCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "kenshincheckup",
        abstract: "config health checks (current: chezmoi-unmanaged)",
        subcommands: [CheckupCommand.self, VersionCommand.self, HelpCommand.self],
        defaultSubcommand: CheckupCommand.self
    )

    public init() {}

    public static func usageLines() -> [String] {
        [
            "kenshincheckup - config health checks (current: chezmoi-unmanaged)",
            "",
            "Usage:",
            "  kenshincheckup",
            "  kenshincheckup help",
            "  kenshincheckup checkup",
            "  kenshincheckup version",
            "  kenshincheckup --help",
            "  kenshincheckup -h",
            "  kenshincheckup checkup --config <path>",
            "  kenshincheckup checkup -c <path>",
            "",
            "Config:",
            "  ~/.config/kenshin/config.toml",
        ]
    }
}

public struct CheckupCommand: ParsableCommand {
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
                patterns: loaded.patterns,
                commandRunner: commandRunner,
                fileManager: .default
            )
            let result = plugin.run()
            OutputFormatter.write(result)
            throw ExitCode(OutputFormatter.exitCode(for: [result]))
        } catch {
            let result = CheckResult(
                name: "doctor_chezmoi_unmanaged",
                description: "Detect unmanaged config files.",
                entries: [
                    CheckEntry(
                        status: .fail,
                        message: "config load failed",
                        details: ["path: \(configURL.path)", "error: \(error)"]
                    ),
                ]
            )
            OutputFormatter.write(result)
            throw ExitCode.failure
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

public struct VersionCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Print version information."
    )

    public init() {}

    public func run() throws {
        print("kenshincheckup dev")
    }
}

public struct HelpCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "help",
        abstract: "Show help."
    )

    public init() {}

    public func run() throws {
        for line in KenshinCheckupCommand.usageLines() {
            print(line)
        }
    }
}
