import Foundation

public struct CliOptions: Equatable {
    public let showHelp: Bool
    public let hasError: Bool
    public let configPath: String?

    public init(showHelp: Bool = false, hasError: Bool = false, configPath: String? = nil) {
        self.showHelp = showHelp
        self.hasError = hasError
        self.configPath = configPath
    }

    public static func parse(_ args: [String]) -> CliOptions {
        var options = CliOptions()
        var index = 0
        while index < args.count {
            let arg = args[index]
            if arg == "help" || arg == "--help" || arg == "-h" {
                options = CliOptions(showHelp: true)
                return options
            }
            if arg == "--config" || arg == "-c" {
                let nextIndex = index + 1
                guard nextIndex < args.count else {
                    return CliOptions(hasError: true)
                }
                options = CliOptions(configPath: args[nextIndex])
                index += 2
                continue
            }
            return CliOptions(hasError: true)
        }
        return options
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
