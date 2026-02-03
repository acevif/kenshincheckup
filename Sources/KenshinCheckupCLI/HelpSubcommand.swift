import ArgumentParser

public struct HelpSubcommand: ParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "help",
        abstract: "Show help."
    )

    public init() {}

    public static func usageText() -> String {
        """
        KenshinCheckup (kenshin) performs multiple doctor checks in one go.

        Repository: https://github.com/acevif/kenshincheckup

        Usage:
          kenshin
          kenshin help
          kenshin checkup
          kenshin version
          kenshin --help
          kenshin -h
          kenshin --version
          kenshin -v
          kenshin --config <path>
          kenshin -c <path>
          kenshin checkup --config <path>
          kenshin checkup -c <path>

        Config:
          ~/.config/kenshin/config.toml
        """
    }

    public func run() throws {
        print(Self.usageText())
    }
}
