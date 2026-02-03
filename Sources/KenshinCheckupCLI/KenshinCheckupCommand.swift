import ArgumentParser
import Foundation
import KenshinCheckupCore

public struct KenshinCheckupCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "kenshin",
        abstract: "config health checks (current: chezmoi-unmanaged)",
        subcommands: [CheckupSubcommand.self, VersionSubcommand.self, HelpSubcommand.self]
    )

    @Option(name: [.short, .long], help: "Path to config file.")
    public var config: String?

    @Flag(name: [.customShort("v"), .long], help: "Print version and exit.")
    public var version: Bool = false

    public init() {}

    public static func usageLines() -> [String] {
        [
            "kenshin - config health checks (current: chezmoi-unmanaged)",
            "",
            "Usage:",
            "  kenshin",
            "  kenshin help",
            "  kenshin checkup",
            "  kenshin version",
            "  kenshin --help",
            "  kenshin -h",
            "  kenshin --version",
            "  kenshin -v",
            "  kenshin --config <path>",
            "  kenshin -c <path>",
            "  kenshin checkup --config <path>",
            "  kenshin checkup -c <path>",
            "",
            "Config:",
            "  ~/.config/kenshin/config.toml",
        ]
    }

    public func run() throws {
        if version {
            print(VersionSubcommand.versionOutput())
            return
        }

        var command = CheckupSubcommand()
        command.config = config
        try command.run()
    }
}
