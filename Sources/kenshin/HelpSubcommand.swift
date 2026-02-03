import ArgumentParser

public struct HelpSubcommand: ParsableCommand {
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
