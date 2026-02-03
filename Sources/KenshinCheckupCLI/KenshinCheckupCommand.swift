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

    public func run() throws {
        if version {
            print(VersionSubcommand.versionOutput())
            return
        }

        var checkupSubcommand = CheckupSubcommand()
        checkupSubcommand.config = config
        try checkupSubcommand.run()
    }
}
