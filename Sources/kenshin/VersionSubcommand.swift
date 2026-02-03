import ArgumentParser

public struct VersionSubcommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Print version information."
    )

    public init() {}

    public func run() throws {
        print(KenshinCheckupCommand.versionOutput())
    }
}
