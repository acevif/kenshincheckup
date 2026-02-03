import ArgumentParser
import KenshinCheckupCore

public struct VersionSubcommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "version",
        abstract: "Print version information."
    )

    public init() {}

    public static func versionOutput() -> String {
        "KenshinCheckup \(Version.string)"
    }

    public func run() throws {
        print(Self.versionOutput())
    }
}
