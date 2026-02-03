import Foundation
import kenshincheckupCore

@main
struct KenshinCheckupApp {
    static func main() {
        let homePath = ProcessInfo.processInfo.environment["HOME"]
            ?? FileManager.default.homeDirectoryForCurrentUser.path
        let configURL = URL(fileURLWithPath: homePath)
            .appendingPathComponent(".config")
            .appendingPathComponent("kenshin")
            .appendingPathComponent("config.toml")

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
}
