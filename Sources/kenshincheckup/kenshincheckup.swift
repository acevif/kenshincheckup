import Foundation
import kenshincheckupCore

@main
struct KenshinCheckupApp {
    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        let parsed = CliOptions.parse(args)
        if parsed.showHelp {
            printUsage()
            exit(0)
        }
        if parsed.hasError {
            printUsage()
            exit(1)
        }

        let homePath = ProcessInfo.processInfo.environment["HOME"]
            ?? FileManager.default.homeDirectoryForCurrentUser.path
        let configPath = parsed.configPath.map { CliOptions.resolvePath($0, homePath: homePath) }
            ?? CliOptions.defaultConfigPath(homePath: homePath)
        let configURL = URL(fileURLWithPath: configPath)

        let commandRunner = SystemCommandRunner()

        do {
            let config = try ConfigLoader.load(from: configURL)
            let plugin = ChezmoiUnmanagedPlugin(
                patterns: config.patterns,
                commandRunner: commandRunner,
                fileManager: .default
            )
            let result = plugin.run()
            OutputFormatter.write(result)
            exit(OutputFormatter.exitCode(for: [result]))
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
            exit(1)
        }
    }

    private static func printUsage() {
        let lines = [
            "kenshincheckup - config health checks (current: chezmoi-unmanaged)",
            "",
            "Usage:",
            "  kenshincheckup",
            "  kenshincheckup help",
            "  kenshincheckup --help",
            "  kenshincheckup -h",
            "  kenshincheckup --config <path>",
            "  kenshincheckup -c <path>",
            "",
            "Config:",
            "  ~/.config/kenshin/config.toml",
        ]
        for line in lines {
            print(line)
        }
    }

}
