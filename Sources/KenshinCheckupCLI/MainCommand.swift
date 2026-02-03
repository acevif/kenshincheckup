import ArgumentParser
import Foundation
import KenshinCheckupCore
import Logging

@main
public struct MainCommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "kenshin",
        abstract: "KenshinCheckup (kenshin) performs multiple doctor checks in one go.",
        discussion: "Find more information at: https://github.com/acevif/kenshincheckup/",
        subcommands: [CheckupSubcommand.self, VersionSubcommand.self]
    )

    @Option(name: [.short, .long], help: "Path to config file. (default: ~/.config/kenshin/config.toml)")
    public var config: String?

    @Flag(name: [.short, .long], help: "Print version and exit.")
    public var version: Bool = false

    public init() {}

    public func run() throws {
        LoggingSystem.bootstrap { label in
            var handler = StreamLogHandler.standardError(label: label)
            handler.logLevel = .debug
            return handler
        }

        if version {
            print(VersionSubcommand.versionOutput())
            return
        }

        var checkupSubcommand = CheckupSubcommand()
        checkupSubcommand.config = config
        try checkupSubcommand.run()
    }
}
